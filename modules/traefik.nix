{ lib, config, ... }:
with lib;
let
  cfg = config.custom.traefik;
  publicEntrypoint = if (isNull cfg.publicIP) then {} else {
    webunsafe = {
      address = "${cfg.publicIP}:80";
      http = {
        redirections.entrypoint.to = "webs";
        redirections.entrypoint.scheme = "https";
      };
    };
    webs = {
      address = "${cfg.publicIP}:443";
      http.tls = true;
    };
  };
  warpEntrypoint = if (isNull cfg.warpIP) then {} else {
    warpunsecure = {
      address = "${cfg.warpIP}:80";
      http = {
        redirections.entrypoint.to = "warps";
        redirections.entrypoint.scheme = "https";
      };
    };
    warps = {
      address = "${cfg.warpIP}:443";
      http.tls = true;
    };
  };
in
{
  options.custom.traefik = {
    enable = mkEnableOption "traefik with nix-declared config";
    acmeDomains = mkOption {
      type = types.listOf types.str;
      default = [ "mlwr.dev" ];
      description = "domains to request TLS certs for using cloudflare";
    };
    entries = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };
          domain = mkOption {
            type = types.str;
          };
          port = mkOption {
            type = types.int;
          };
          target = mkOption {
            type = types.str;
            default = "localhost";
            description = "host to forward to";
          };
          middlewares = mkOption {
            # too lazy to setup this properly
            type = types.listOf types.attrs;
            default = [];
            description = "traefik middlewares to use";
          };
          entrypoints = mkOption {
            type = types.listOf types.str;
            default = [ "webs" ];
            description = "list of entrypoints to listen on";
          };
        };
      });
      description = "traefik config entries";
    };
    email = mkOption {
      type = types.str;
      default = "cloudflare@bonusplay.pl";
      description = "admin email for acme";
    };
    publicIP = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "public IP to listen on";
    };
    warpIP = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "warp-net IP to listen on";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.cloudflare = {
      file = ../secrets/cloudflare.age;
      mode = "0400";
    };

    security.acme = let
      mkCertEntry = domain: {
        "${domain}" = {
          domain = "*.${domain}";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.cloudflare.path;
          email = cfg.email;
          renewInterval = "weekly";
          group = "traefik";
          reloadServices = [ "traefik" ];
        };
      };
      certEntries = map mkCertEntry cfg.acmeDomains;
      acmeConfig = lib.foldl' lib.recursiveUpdate {} certEntries;
    in {
      acceptTerms = true;
      certs = acmeConfig;
    };

    networking.firewall.allowedTCPPorts = [ 443 ];

    services.traefik = {
      enable = true;
      staticConfigOptions = {
        experimental = {
          http3 = true;
        };
        api = {
          dashboard = true;
        };
        entryPoints = publicEntrypoint // warpEntrypoint;
      };
      dynamicConfigOptions =
        let
          # traefik fails to load config if there are no middlewares
          # but middleware field is empty, this is a hacky workaround
          dummyMiddleware = {
            dummy.headers.customResponseHeaders.hehe = "potega";
          };
          mkHttpEntry = entry: {
            routers."${entry.name}" = {
              rule = "Host(`${entry.domain}`)";
              service = entry.name;
              entrypoints = entry.entrypoints;
              middlewares = lib.flatten (map lib.attrNames entry.middlewares);
            };
            services."${entry.name}".loadBalancer.servers = [{
              url = "http://${entry.target}:${toString entry.port}";
            }];
            middlewares = dummyMiddleware // (lib.foldl' lib.recursiveUpdate {} entry.middlewares);
          };
          httpEntries = map mkHttpEntry cfg.entries;
          httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;

          mkTlsEntry = domain: {
            certFile = "/var/lib/acme/${domain}/cert.pem";
            keyFile = "/var/lib/acme/${domain}/key.pem";
          };
          tlsConfig = map mkTlsEntry cfg.acmeDomains;
        in
        {
          http = httpConfig;
          tls.certificates = tlsConfig;
        };
    };
  };
}
