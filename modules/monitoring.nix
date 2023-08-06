{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.monitoring;
in
{
  options.custom.monitoring = {
    enable = mkEnableOption "monitoring using prom-node-exporter + promtail";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      config.services.prometheus.exporters.node.port
      config.services.prometheus.exporters.systemd.port
    ];

    services.prometheus = {
      exporters = {
        node = {
          enable = true;
        };
        systemd = {
          enable = true;
        };
      };
    };

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
          grpc_listen_port = 0;
        };

        positions = {
          filename = "/tmp/positions.yaml";
        };

        clients = [
          {
            url = "https://loki.mlwr.dev/loki/api/v1/push";
          }
        ];

        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "${config.networking.hostName}";
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };
  };
}
