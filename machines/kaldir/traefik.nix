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
        group = "traefik";
        reloadServices = [ "traefik" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      experimental = {
        http3 = true;
      };
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          khala = {
            rule = "Host(`khala.bonusplay.pl`)";
            service = "khala";
          };
          khala-ui = {
            rule = "Host(`khala.bonusplay.pl`) && PathPrefix(`/web`)";
            service = "khala-ui";
          };
        };
        services = {
          khala.loadBalancer.servers = [{
            url = "http://localhost:4040";
          }];
          khala-ui.loadBalancer.servers = [{
            url = "http://localhost:4050";
          }];
        };
      };
    };
  };
}
