{ lib, config, ... }:
with lib;
let
  cfg = config.custom.caddy;
  recursiveMerge = objs: lib.foldl' lib.recursiveUpdate {} objs;

  isPrivateDomain = entry: lib.hasSuffix ".lan" entry.domain;
  isPublicDomain = entry: !(isPrivateDomain entry);
  publicDomains = map (entry: entry.domain) (builtins.filter isPublicDomain cfg.entries);
  splitDomain = domain: lib.splitString "." domain;

  # "mail.google.com" => ["mail" "gogole" "com"] => ["com" "google" "mail"] =>
  # ["com" "google"] => ["google" "com"] => "google.com"
  extractMainDomain = domain: lib.concatStringsSep "." (lib.reverseList (lib.take 2 (lib.reverseList (splitDomain domain))));

  publicMainDomains = lib.lists.unique (map extractMainDomain publicDomains);
  hasPrivateDomains = builtins.any isPrivateDomain cfg.entries;
in
{
  options.custom.caddy = {
    enable = mkEnableOption "caddy with more convenience";
    entries = mkOption {
      default = [];
      type = types.listOf (types.submodule {
        options = {
          domain = mkOption {
            type = types.str;
          };
          entrypoints = mkOption {
            type = types.listOf types.str;
            default = [ "0.0.0.0" ];
          };
          target = mkOption {
            type = types.nullOr types.str;
            default = "localhost";
            description = "host to forward to";
          };
          port = mkOption {
            type = types.nullOr types.int;
            description = "port to forward to";
          };
          extraConfig = mkOption {
            type = types.str;
            default = "";
            description = "extra config per domain";
          };
          extraProxyConfig = mkOption {
            type = types.str;
            default = "";
            description = "extra config in reverse_proxy block";
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    age.secrets.cloudflare = mkIf (publicMainDomains != []) {
      file = ../secrets/cloudflare.age;
      mode = "0400";
    };

    # we do it this way to get wildcard cert
    security.acme = let
      mkCertEntry = domain: {
        "${domain}" = {
          domain = "*.${domain}";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.cloudflare.path;
          email = "acme@${domain}";
          renewInterval = "weekly";
          group = "caddy";
          reloadServices = [ "caddy" ];
        };
      };
    in {
      acceptTerms = true;
      certs = recursiveMerge (map mkCertEntry publicMainDomains); 
    };

    networking.firewall.allowedTCPPorts = [ 443 ];

    systemd.services.caddy = mkIf hasPrivateDomains {
      wants = ["tailscaled.service"];
      after = ["tailscaled.service"];
    };

    services.caddy = let
      acmeDir = entry: "/var/lib/acme/${extractMainDomain entry.domain}";
      proxyEntry = entry: if entry.target == null && entry.port == null then "" else ''
        reverse_proxy http://${entry.target}:${toString entry.port} {
          header_down -Server
          ${entry.extraProxyConfig}
        }
      '';
      mkPubDomainEntry = entry: {
        ${entry.domain} = {
          listenAddresses = entry.entrypoints;
          extraConfig = ''
            tls ${acmeDir entry}/fullchain.pem ${acmeDir entry}/key.pem
            header -Server
            ${entry.extraConfig}
            ${proxyEntry entry}
          '';
        };
      };
      mkLanDomainEntry = entry: {
        ${entry.domain} = {
          #hostName = entry.domain;
          listenAddresses = entry.entrypoints;
          extraConfig = ''
            tls {
              curves secp384r1
              key_type p384
              issuer acme {
                dir https://pki.warp.lan/acme/warp/directory
                email acme@${entry.domain}
                trusted_roots ${../files/warp-net-root.crt}
                disable_http_challenge
              }
            }
            header -Server
            ${entry.extraConfig}
            ${proxyEntry entry}
          '';
        };
      };
      mkDomainEntry = entry: if (isPublicDomain entry) then (mkPubDomainEntry entry) else (mkLanDomainEntry entry);
      domainEntries = map mkDomainEntry cfg.entries;
    in {
      enable = true;
      virtualHosts = recursiveMerge domainEntries;
    };
  };
}
