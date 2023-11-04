{ config, ... }:
let
  port = config.containers.grafana.config.services.grafana.settings.server.http_port;
in
{
  custom.traefik.entries = [
    {
      name = "grafana";
      domain = config.containers.grafana.config.services.grafana.settings.server.domain;
      target = config.containers.grafana.localAddress;
      port = port;
      entrypoints = [ "warps" ];
    }
  ];

  containers.grafana = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.0.1";
    localAddress = "172.28.0.2";

    config = { config, ... }: {
      services.grafana = {
        enable = true;
        settings.server = {
          domain = "graf.mlwr.dev";
          root_url = "https://graf.mlwr.dev/";
          http_addr = "172.28.0.2";
          http_port = 4060;
        };
        provision = {
          enable = true;
          datasources.settings = {
            apiVersion = 1;
            datasources = [
              {
                type = "prometheus";
                name = "prometheus";
                url = "https://prom.mlwr.dev";
              }
              {
                type = "loki";
                name = "loki";
                url = "https://loki.mlwr.dev";
              }
            ];
          };
        };
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };

      system.stateVersion = "23.05";
    };
  };
}
