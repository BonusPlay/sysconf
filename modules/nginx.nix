{ lib, config, ... }:
with lib;
let
  cfg = config.custom.nginx;
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
  options.custom.nginx = {
    enable = mkEnableOption "nginx with more convenience";
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
        };
      });
    };
  };

  config = mkIf cfg.enable {
    # required for acme
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.nginx = mkIf hasPrivateDomains {
      wants = ["tailscaled.service"];
      after = ["tailscaled.service"];
    };

    security.acme = let
      mkPrivCertEntry = entry: {
        "${entry.domain}" = {
          server = "https://pki.warp.lan/acme/warp/directory";
          email = "acme@${entry.domain}";
          renewInterval = "daily";
          group = "nginx";
          reloadServices = [ "nginx" ];
        };
      };
      mkPubCertEntry = domain: {};
      mkCertEntry = entry: if (isPublicDomain entry) then (mkPubCertEntry entry) else (mkPrivCertEntry entry);
    in {
      acceptTerms = true;
      certs = recursiveMerge (map mkCertEntry cfg.entries);
    };

    services.nginx = let
      proxyEntry = entry: if entry.target == null && entry.port == null then {} else {
        "/" = {
          proxyPass = "http://${entry.target}:${toString entry.port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      mkDomainEntry = entry: "";
      domainEntries = map mkDomainEntry cfg.entries;
    in {
      enable = true;
      virtualHosts = recursiveMerge domainEntries;
    };
  };
}
