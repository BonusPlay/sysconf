{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.traefik;
in
}:
{
  options.custom.traefik = {
    enable = mkEnableOption "traefik with nix-declared config";
    acmeDomains = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "domains to request TLS certs for using cloudflare";
    };
    entries = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "traefik config entries";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.cloudflare = {
      file = ../../secrets/cloudflare.age;
      mode = "0400";
    };

    security.acme = let
      mkCertEntry = domain: {
        "${domain}" = {
          domain = "*.${domain}";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.cloudflare.path;
          email = "cloudflare@bonusplay.pl";
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
        entryPoints = {
          web = {
            address = ":80";
            http = {
              redirections.entrypoint.to = "websecure";
              redirections.entrypoint.scheme = "https";
            };
          };
          websecure = {
            address = ":443";
            http.tls = true;
          };
        };
      };
      dynamicConfigOptions =
        let
          mkHttpEntry = entry: {
            routers."${entry.name}" = {
              rule = "Host(`${entry.domain}`)";
              service = entry.name;
              entrypoints = entry.entrypoints or [ "websecure" ];
            };
            services."${entry.name}".loadBalancer.servers = [{
              url = "http://${entry.target or "localhost"}:${toString entry.port}";
            }];
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
