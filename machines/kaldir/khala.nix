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
    port = 8080;
    serverUrl = "https://kaldir.bonusplay.pl";
    tls.letsencrypt.hostname = "*.bonusplay.pl";
    tls.letsencrypt.httpListen = ":8081";
  };
}
