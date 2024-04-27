{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.monitoring;
in
{
  imports = [
    ./grafna-alloy.nix
  ];

  options.custom.monitoring = {
    enable = mkEnableOption "monitoring";
  };

  config = mkIf cfg.enable {
    age.secrets.grafana-alloy = {
      file = ../secrets/grafana-alloy.age;
      mode = "0400";
      owner = "grafana-alloy";
    };

    services.grafana-alloy = {
      enable = true;
      environmentFile = config.age.secrets.grafana-alloy.path;
      configuration = ''
        prometheus.exporter.unix "local_metrics" {}

        prometheus.scrape "local_prom" {
          scrape_interval = "10s"
          targets = prometheus.exporter.unix.local_metrics.targets
          forward_to = [ prometheus.remote_write.remote_prom.receiver, ]
        }

        loki.source.journal "local_journald" {
          forward_to    = [ loki.write.remote_loki.receiver ]
        }

        prometheus.remote_write "remote_prom" {
          endpoint {
            url = env("PROMETHEUS_URL")
            basic_auth {
              username = env("PROMETHEUS_USERNAME")
              password = env("PROMETHEUS_PASSWORD")
            }
          }
        }

        loki.write "remote_loki" {
          endpoint {
            url = env("LOKI_URL")
            basic_auth {
              username = env("LOKI_USERNAME")
              password = env("LOKI_PASSWORD")
            }
          }
        }
      '';
    };
  };
}
