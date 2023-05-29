{ lib, config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "mlwr.dev" = {
        domain = "*.mlwr.dev";
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
      api = {
        dashboard = true;
        insecure = true;
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
        entries = [
          {
            name = "git";
            domain = "git.mlwr.dev";
            port = config.services.gitea.settings.server.HTTP_PORT;
          }
        ];
        mkHttpEntry = entry: {
          routers."${entry.name}" = {
            rule = "Host(`${entry.domain}`)";
            service = entry.name;
            entrypoints = [ "websecure" ];
          };
          services."${entry.name}".loadBalancer.servers = [{
            url = "http://${entry.target or "localhost"}:${toString entry.port}";
          }];
        };
        httpEntries = map mkHttpEntry entries;
        httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;
      in
      {
        http = httpConfig;
        tls.certificates = [
          {
            certFile = "/var/lib/acme/mlwr.dev/cert.pem";
            keyFile = "/var/lib/acme/mlwr.dev/key.pem";
          }
        ];
      };
  };
}
