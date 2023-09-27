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
          address = "10.0.0.131:80";
          http = {
            redirections.entrypoint.to = "websecure";
            redirections.entrypoint.scheme = "https";
          };
        };
        websecure = {
          address = "10.0.0.131:443";
          http.tls = true;
        };
        warp = {
          address = "100.98.118.66:80";
          http = {
            redirections.entrypoint.to = "websecure";
            redirections.entrypoint.scheme = "https";
          };
        };
        warpsecure = {
          address = "100.98.118.66:443";
          http.tls = true;
        };
      };
    };
    dynamicConfigOptions =
      let
        entries = [
          {
            name = "matrix";
            domain = "matrix.bonusplay.pl";
            port = 4080;
            middlewares = [];
            entrypoints = [ "websecure" ];
          }
          {
            name = "docker-registry";
            domain = "dr.bonusplay.pl";
            port = 4070;
            middlewares = [{
              drAuth.basicAuth.usersFile = config.age.secrets.drUsersFile.path;
            }];
            entrypoints = [ "websecure" ];
          }
          {
            name = "prometheus";
            domain = lib.strings.removeSuffix "/" (lib.strings.removePrefix "https://" config.services.prometheus.webExternalUrl);
            port = config.services.prometheus.port;
            middlewares = [];
            entrypoints = [ "warpsecure" ];
          }
          {
            name = "grafana";
            domain = config.services.grafana.settings.server.domain;
            port = config.services.grafana.settings.server.http_port;
            middlewares = [];
            entrypoints = [ "warpsecure" ];
          }
          {
            name = "loki";
            domain = "loki.mlwr.dev";
            port = config.services.loki.configuration.server.http_listen_port;
            middlewares = [];
            entrypoints = [ "warpsecure" ];
          }
          {
            name = "influx";
            domain = "influx.mlwr.dev";
            port = lib.toInt (lib.strings.removePrefix "localhost:" config.services.influxdb2.settings.http-bind-address);
            middlewares = [];
            entrypoints = [ "warpsecure" ];
          }
        ];
        mkHttpEntry = entry: {
          routers."${entry.name}" = {
            rule = "Host(`${entry.domain}`)";
            service = entry.name;
            middlewares = lib.flatten (map lib.attrNames entry.middlewares);
            entrypoints = entry.entrypoints;
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
