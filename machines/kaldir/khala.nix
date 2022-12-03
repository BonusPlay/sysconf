{ config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    mode = "0440";
    group = "headscale";
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      wildcard = {
        dnsProvider = "cloudflare";
        renewInterval = "weekly";
        email = "cloudflare@bonusplay.pl";
        reloadServices = [ "headscale" ];
        domain = "*.bonusplay.pl";
        credentialsFile = config.age.secrets.cloudflare.path;
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
