{ lib, config, ... }:
{
  age.secrets.giteaCertKey = {
    file = ../../secrets/gitea-ssl-key.age;
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
        entries = [
          {
            name = "git";
            domain = "git.bonus.p4";
            kind = "http";
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
            certFile = "/etc/nixos/files/p4net/git.bonus.p4.crt";
            keyFile = config.age.secrets.giteaCertKey.path;
          }
        ];
      };
  };
}
