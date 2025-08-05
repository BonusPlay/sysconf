{ lib, config, ... }:
let
  cfg = config.custom.caddy;
  recursiveMerge = objs: lib.foldl' lib.recursiveUpdate {} objs;

  # "mail.google.com" => ["mail" "google" "com"]
  splitDomain = domain: lib.splitString "." domain;

  # "mail.google.com" => ["mail" "gogole" "com"] => ["com" "google" "mail"] =>
  # ["com" "google"] => ["google" "com"] => "google.com"
  extractMainDomain = domain: lib.concatStringsSep "." (lib.reverseList (lib.take 2 (lib.reverseList (splitDomain domain))));

  domains = map (entry: entry.domain) cfg.entries;
  mainDomains = lib.lists.unique (map extractMainDomain domains);
in
{
  options.custom.caddy = {
    enable = lib.mkEnableOption "caddy with more convenience";
    entries = lib.mkOption {
      default = [];
      type = lib.types.listOf (lib.types.submodule {
        options = {
          domain = lib.mkOption {
            type = lib.types.str;
          };
          entrypoints = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "0.0.0.0" ];
          };
          target = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = "localhost";
            description = "host to forward to";
          };
          port = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            description = "port to forward to";
          };
          extraConfig = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "extra config per domain";
          };
          extraProxyConfig = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "extra config in reverse_proxy block";
          };
          allowTier1 = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "allow Tier1 users to access";
          };
          allowTier2 = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "allow Tier2 users to access";
          };
          isPublic = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "allow service without mTLS";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      cloudflare = {
        file = ../secrets/cloudflare.age;
        mode = "0400";
      };
      tier0 = {
        file = ../secrets/ca/tier0-crt.age;
        mode = "0400";
        owner = "caddy";
      };
      tier1 = {
        file = ../secrets/ca/tier1-crt.age;
        mode = "0400";
        owner = "caddy";
      };
      tier2 = {
        file = ../secrets/ca/tier2-crt.age;
        mode = "0400";
        owner = "caddy";
      };
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
      certs = recursiveMerge (map mkCertEntry mainDomains);
    };

    networking.firewall.allowedTCPPorts = [ 443 ];

    services.caddy = let
      acmeDir = entry: "/var/lib/acme/${extractMainDomain entry.domain}";
      proxyEntry = entry: if entry.target == null && entry.port == null then "" else ''
        reverse_proxy http://${entry.target}:${toString entry.port} {
          header_down -Server
          ${entry.extraProxyConfig}
        }
      '';

      mkTlsCfg = entry: if entry.isPublic then "" else ''
        import tier0
        ${if entry.allowTier1 then "import tier1" else ""}
        ${if entry.allowTier2 then "import tier2" else ""}
      '';
      mkTierCfg = level: ''
        (tier${toString level}) {
          protocols tls1.3
          client_auth {
            mode require_and_verify
            trust_pool file ${config.age.secrets."tier${toString level}".path}
          }
        }
      '';
      mkDomainEntry = entry: {
        ${entry.domain} = {
          listenAddresses = entry.entrypoints;
          extraConfig = ''
            tls ${acmeDir entry}/fullchain.pem ${acmeDir entry}/key.pem {
              ${mkTlsCfg entry}
            }
            header -Server
            ${entry.extraConfig}
            ${proxyEntry entry}
          '';
        };
      };
      domainEntries = map mkDomainEntry cfg.entries;
    in {
      enable = true;
      virtualHosts = recursiveMerge domainEntries;
      extraConfig = ''
        ${mkTierCfg 0}
        ${mkTierCfg 1}
        ${mkTierCfg 2}
      '';
    };
  };
}
