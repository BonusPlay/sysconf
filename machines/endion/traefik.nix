{ lib, config, ... }:
{
  age.secrets.giteaCertKey = {
    file = ../../secrets/prometheus-ssl-key.age;
    mode = "0400";
    owner = "traefik";
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
        p4netMiddleware = {
          p4net.ipwhitelist.sourcerange = "127.0.0.1/32, 198.18.0.0/16";
        };
        entries = [
          {
            name = "git";
            domain = "git.bonus.p4";
            kind = "http";
            port = config.services.gitea.httpPort;
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
            certFile = "/etc/nixos/files/p4net/git.bonus.p4.crt";
            keyFile = config.age.secrets.giteaCertKey.path;
          }
        ];
      };
  };
}
