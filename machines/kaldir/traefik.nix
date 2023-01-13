{ lib, config, ... }:
{
  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare.age;
    mode = "0400";
  };

  age.secrets.prometheusCertKey = {
    file = ../../secrets/prometheus-ssl-key.age;
    mode = "0400";
    owner = "traefik";
  };

  age.secrets.grafanaCertKey = {
    file = ../../secrets/grafana-ssl-key.age;
    mode = "0400";
    owner = "traefik";
  };

  age.secrets.lokiCertKey = {
    file = ../../secrets/loki-ssl-key.age;
    mode = "0400";
    owner = "traefik";
  };

  age.secrets.drUsersFile = {
    file = ../../secrets/dr-bonus-p4-users.age;
    mode = "0400";
    owner = "traefik";
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
        mqtt = {
          address = ":8883";
        };
      };
    };
    dynamicConfigOptions =
      let
        p4netMiddleware = {
          p4net.ipwhitelist.sourcerange = "127.0.0.1/32, 198.18.0.0/16";
        };
        entries = [
          {
            name = "matrix";
            domain = "matrix.bonusplay.pl";
            kind = "http";
            port = 4080;
            middlewares = [];
          }
          {
            name = "dr";
            domain = "dr.bonusplay.pl";
            kind = "http";
            port = 4070;
            target = config.containers.dockerRegistry.localAddress;
            middlewares = [
              {
                drAuth.basicAuth.usersFile = config.age.secrets.drUsersFile.path;
              }
            ];
          }
          {
            name = "mqtt";
            domain = "mqtt.bonusplay.pl";
            kind = "tcp";
            port = 8883;
            target = config.containers.mosquitto.localAddress;
            entrypoints = [ "mqtt" ];
          }
          {
            name = "prometheus";
            domain = lib.strings.removeSuffix "/" (lib.strings.removePrefix "https://" config.services.prometheus.webExternalUrl);
            kind = "http";
            port = config.services.prometheus.port;
            p4net = true;
            middlewares = [ p4netMiddleware ];
          }
          {
            name = "grafana";
            domain = config.services.grafana.settings.server.domain;
            kind = "http";
            port = config.services.grafana.settings.server.http_port;
            middlewares = [ p4netMiddleware ];
          }
          {
            name = "loki";
            domain = "loki.bonus.p4";
            kind = "http";
            port = config.services.loki.configuration.server.http_listen_port;
            middlewares = [ p4netMiddleware ];
          }
        ];
        isHttp = entry: entry.kind == "http";
        isTcp = entry: entry.kind == "tcp";

        mkHttpEntry = entry: {
          routers."${entry.name}" = {
            rule = "Host(`${entry.domain}`)";
            service = entry.name;
            middlewares = lib.flatten (map lib.attrNames entry.middlewares);
            entrypoints = [ "websecure" ];
          };
          services."${entry.name}".loadBalancer.servers = [{
            url = "http://${entry.target or "localhost"}:${toString entry.port}";
          }];
          middlewares = lib.foldl' lib.recursiveUpdate {} entry.middlewares;
        };

        mkTcpEntry = entry: {
          routers."${entry.name}" = {
            rule = "HostSNI(`${entry.domain}`)";
            service = entry.name;
            tls = {};
            entrypoints = entry.entrypoints;
          };
          services."${entry.name}".loadBalancer.servers = [{
            address = "${entry.target or "localhost"}:${toString entry.port}";
          }];
        };

        httpEntries = map mkHttpEntry (lib.filter isHttp entries);
        tcpEntries = map mkTcpEntry (lib.filter isTcp entries);

        httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;
        tcpConfig = lib.foldl' lib.recursiveUpdate {} tcpEntries;
      in
      {
        http = httpConfig;
        tcp = tcpConfig;
        tls.certificates = [
          {
            certFile = "/var/lib/acme/wildcard/cert.pem";
            keyFile = "/var/lib/acme/wildcard/key.pem";
          }
          {
            certFile = "/etc/nixos/files/p4net/prom.bonus.p4.crt";
            keyFile = config.age.secrets.prometheusCertKey.path;
          }
          {
            certFile = "/etc/nixos/files/p4net/graf.bonus.p4.crt";
            keyFile = config.age.secrets.grafanaCertKey.path;
          }
          {
            certFile = "/etc/nixos/files/p4net/loki.bonus.p4.crt";
            keyFile = config.age.secrets.lokiCertKey.path;
          }
        ];
      };
  };
}
