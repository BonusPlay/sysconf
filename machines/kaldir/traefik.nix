{ lib, config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    mode = "0400";
  };

  age.secrets.drUsersFile = {
    file = ../../secrets/docker-registry-users.age;
    mode = "0400";
    owner = "traefik";
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "bonusplay.pl" = {
        domain = "*.bonusplay.pl";
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.cloudflare.path;
        email = "cloudflare@bonusplay.pl";
        renewInterval = "weekly";
        group = "traefik";
        reloadServices = [ "traefik" ];
      };
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
        warpnetMiddleware = {
          warpnet.ipwhitelist.sourcerange = "127.0.0.1/32, 10.20.30.0/24";
        };
        entries = [
          {
            name = "matrix";
            domain = "matrix.bonusplay.pl";
            port = 4080;
            middlewares = [];
          }
          {
            name = "docker-registry";
            domain = "dr.bonusplay.pl";
            port = 4070;
            middlewares = [{
              drAuth.basicAuth.usersFile = config.age.secrets.drUsersFile.path;
            }];
          }
          {
            name = "prometheus";
            domain = lib.strings.removeSuffix "/" (lib.strings.removePrefix "https://" config.services.prometheus.webExternalUrl);
            port = config.services.prometheus.port;
            middlewares = [ warpnetMiddleware ];
          }
          {
            name = "grafana";
            domain = config.services.grafana.settings.server.domain;
            port = config.services.grafana.settings.server.http_port;
            middlewares = [ warpnetMiddleware ];
          }
          {
            name = "loki";
            domain = "loki.mlwr.dev";
            port = config.services.loki.configuration.server.http_listen_port;
            middlewares = [ warpnetMiddleware ];
          }
          {
            name = "seafile";
            domain = "s.bonusplay.pl";
            port = 80; # nginx inside container does proxy pass to unix socket
            middlewares = [];
          }
        ];
        mkHttpEntry = entry: {
          routers."${entry.name}" = {
            rule = "Host(`${entry.domain}`)";
            service = entry.name;
            middlewares = lib.flatten (map lib.attrNames entry.middlewares);
            entrypoints = [ "websecure" ];
          };
          services."${entry.name}".loadBalancer.servers = [{
            url = "http://127.0.0.1:${toString entry.port}";
          }];
          middlewares = lib.foldl' lib.recursiveUpdate {} entry.middlewares;
        };
        httpEntries = map mkHttpEntry entries;
        httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;
      in
      {
        http = httpConfig;
        tls.certificates = [
          {
            certFile = "/var/lib/acme/bonusplay.pl/cert.pem";
            keyFile = "/var/lib/acme/bonusplay.pl/key.pem";
          }
          {
            certFile = "/var/lib/acme/mlwr.dev/cert.pem";
            keyFile = "/var/lib/acme/mlwr.dev/key.pem";
          }
        ];
      };
  };
}
