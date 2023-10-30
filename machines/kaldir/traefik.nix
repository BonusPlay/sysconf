{ lib, config, ... }:
{
  age.secrets.drUsersFile = {
    file = ../../secrets/docker-registry-users.age;
    mode = "0400";
    owner = "traefik";
  };

  age.secrets.nextcloudUsersFile = {
    file = ../../secrets/nextcloud/basic-auth.age;
    mode = "0400";
    owner = "traefik";
  };

  custom.traefik = {
    enable = true;
    acmeDomains = [ "bonusplay.pl" "mlwr.dev" ];
    publicIP = "10.0.0.131";
    warpIP = "100.98.118.66";
    entries = [
      {
        name = "matrix";
        domain = "matrix.bonusplay.pl";
        port = 4080;
        entrypoints = [ "webs" ];
      }
      {
        name = "docker-registry";
        domain = "dr.bonusplay.pl";
        port = 4070;
        middlewares = [{
          drAuth.basicAuth.usersFile = config.age.secrets.drUsersFile.path;
        }];
        entrypoints = [ "webs" ];
      }
      {
        name = "prometheus";
        domain = lib.strings.removeSuffix "/" (lib.strings.removePrefix "https://" config.services.prometheus.webExternalUrl);
        port = config.services.prometheus.port;
        entrypoints = [ "warps" ];
      }
      {
        name = "grafana";
        domain = config.services.grafana.settings.server.domain;
        port = config.services.grafana.settings.server.http_port;
        entrypoints = [ "warps" ];
      }
      {
        name = "loki";
        domain = "loki.mlwr.dev";
        port = config.services.loki.configuration.server.http_listen_port;
        entrypoints = [ "warps" ];
      }
      {
        name = "influx";
        domain = "influx.mlwr.dev";
        port = lib.toInt (lib.strings.removePrefix "127.0.0.1:" config.services.influxdb2.settings.http-bind-address);
        entrypoints = [ "warps" ];
      }
      {
        name = "nextcloud";
        domain = "nextcloud.bonusplay.pl";
        target = config.containers.nextcloud.localAddress;
        port = 80;
        middlewares = [{
          nextcloudAuth.basicAuth = {
            usersFile = config.age.secrets.nextcloudUsersFile.path;
            removeHeader = true;
          };
          nextcloudHeaders.headers = {
            hostsProxyHeaders = [
              "X-Forwarded-Host"
            ];
            referrerPolicy = "same-origin";
          };
        }];
        entrypoints = [ "webs" ];
      }
    ];
  };
}
