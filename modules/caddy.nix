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
          bindAddr = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = null;
            description = "address to bind on";
          };
          bindPort = lib.mkOption {
            type = lib.types.port;
            default = 443;
            description = "port to listen on";
          };
          target = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = "localhost";
            description = "host to forward to";
          };
          toPort = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            description = "port to forward to";
            default = null;
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
        owner = "caddy";
      };
      mtls-ca = {
        # TODO: new CA
        file = ../secrets/ca/tier0-crt.age;
        mode = "0400";
        owner = "caddy";
      };
      authDefault = {
        file = ../secrets/ca/auth-default.age;
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

    networking.firewall.allowedTCPPorts = map (item: item.bindPort) cfg.entries;

    services.caddy = let
      acmeDir = entry: "/var/lib/acme/${extractMainDomain entry.domain}";
      authFile = entry: if (entry ? allowedFile) then entry.allowedFile else config.age.secrets.authDefault.path;
      authCheck = entry: if entry.isPublic then "" else ''
        map {tls_client_subject} {is_allowed} {
          import ${authFile entry}
          default 0
        }

        @denied vars {is_allowed} 0
        handle @denied {
          respond <<END
            Hello {tls_client_subject}, you do not have access to this service.
            If you think this is a mistake, contact Bonus.
          END 403
        }
      '';
      proxyEntry = entry: if entry.target == null && entry.toPort == null then "" else ''
        reverse_proxy ${entry.target}:${toString entry.toPort} {
          header_down -Server
          ${entry.extraProxyConfig}
        }
      '';

      mkDomainEntry = entry: {
        "${entry.domain}:${toString entry.bindPort}" = {
          listenAddresses = lib.mkIf (entry.bindAddr != null) entry.bindAddr;
          extraConfig = ''
            tls ${acmeDir entry}/fullchain.pem ${acmeDir entry}/key.pem {
              ${if entry.isPublic then "" else "import mtls-ca"}
            }
            header -Server
            ${authCheck entry}
            ${entry.extraConfig}
            ${proxyEntry entry}
          '';
        };
      };
      domainEntries = map mkDomainEntry cfg.entries;
    in {
      enable = true;
      virtualHosts = recursiveMerge domainEntries;
      globalConfig = ''
        debug
      '';
      extraConfig = ''
        (mtls-ca) {
          protocols tls1.3
          client_auth {
            mode require_and_verify
            trust_pool file ${config.age.secrets.mtls-ca.path}
          }
        }
      '';
    };
  };
}
