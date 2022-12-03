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
    settings = {
      ip_prefixes = "198.18.66.0/24";
      tls_client_auth_mode = "disabled";
    };
  };

  networking.firewall.allowedTCPPorts = [ 51850 ];
}
