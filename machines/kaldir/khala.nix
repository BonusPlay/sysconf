{ config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      wildcard = {
        domain = "*.bonusplay.pl";
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.cloudflare.path;
        email = "cloudflare@bonusplay.pl";
        renewInterval = "weekly";
        group = "headscale";
        reloadServices = [ "headscale" ];
      };
    };
  };

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 51850;
    serverUrl = "https://kaldir.bonusplay.pl";
    tls.keyFile = "/var/lib/acme/wildcard/key.pem";
    tls.certFile = "/var/lib/acme/wildcard/cert.pem";
    aclPolicyFile = "/etc/headscale/acl.json";
    settings = {
      ip_prefixes = "198.18.66.0/24";
      tls_client_auth_mode = "disabled";
    };
  };

  networking.firewall.allowedTCPPorts = [ 51850 ];

  services.tailscale = {
    enable = true;
    interfaceName = "p4net-khala";
  };

  environment.etc."headscale/acl.json" = let
    aclConfig = {
      groups = {
        "group:bonus" = [ "bonus" ];
        "group:servers" = [ "kaldir" ];
      };
      tagOwners = {
        "tag:servers" = [ "group:servers" ];
      };
      acls = [
        {
          action = "accept";
          src = [ "bonus" ];
          dst = [ "bonus:*" ];
        }
        {
          action = "accept";
          src = [ "group:bonus" ];
          dst = [ "tag:servers:*" ];
        }
      ];
    };
  in {
    user = "headscale";
    mode = "0660";
    text = builtins.toJSON aclConfig;
  };
}
