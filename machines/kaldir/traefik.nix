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
        entries = [
          {
            name = "matrix";
            domain = "matrix.bonusplay.pl";
            kind = "http";
            port = 4080;
            p4net = false;
          }
          {
            name = "dr";
            domain = "dr.bonusplay.pl";
            kind = "http";
            port = 4070;
            p4net = false;
          }
          {
            name = "mqtt";
            domain = "mqtt.bonusplay.pl";
            kind = "tcp";
            port = 8883;
            p4net = false;
          }
          {
            name = "prometheus";
            domain = config.services.prometheus.webExternalUrl;
            kind = "http";
            port = config.services.prometheus.port;
            p4net = true;
          }
          {
            name = "grafana";
            domain = config.services.grafana.settings.server.domain;
            kind = "http";
            port = config.services.grafana.settings.server.http_port;
            p4net = true;
          }
        ];
        isHttp = entry: entry.kind == "http";
        isTcp = entry: entry.kind == "tcp";

        mkHttpEntry = entry: {
          routers."${entry.name}" = {
            rule = "Host(`${entry.domain}`)";
            service = entry.name;
          };
          services."${entry.name}".loadBalancer.servers = [{
            url = "http://localhost:${toString entry.port}";
          }];
        };

        mkTcpEntry = entry: {
          routers."${entry.name}" = {
            rule = "HostSNI(`${entry.domain}`)";
            service = entry.name;
            tls = {};
          };
          services."${entry.name}".loadBalancer.servers = [{
            address = "localhost:${toString entry.port}";
          }];
        };

        httpEntries = map mkHttpEntry (lib.filter isHttp entries);
        tcpEntries = map mkTcpEntry (lib.filter isTcp entries);

        httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;
        tcpConfig = lib.foldl' lib.recursiveUpdate {} tcpEntries;
      in
      {
        # TODO: rewrite using nix
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
        ];
      };
  };
}
