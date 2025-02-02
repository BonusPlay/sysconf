{ lib, config, pkgs, ... }:
let
  cfg = config.custom.monitoring;
  port = 45876;
in
{
  imports = [
    ./grafna-alloy.nix
  ];

  options.custom.monitoring = {
    enable = lib.mkEnableOption "monitoring";
  };

  config = lib.mkIf cfg.enable {
    custom.beszel-agent = {
      enable = true;
      environmentFile = config.age.secrets.beszel-env.path;
      environment.PORT = toString port;
    };

    age.secrets.beszel-env = {
      file = ../secrets/beszel-env.age;
      mode = "0400";
      owner = config.custom.beszel-agent.user;
    };

    networking.firewall.allowedTCPPorts = [ port ];

    age.secrets.grafana-alloy = {
      file = ../secrets/grafana-alloy.age;
      mode = "0400";
      owner = "grafana-alloy";
    };

    services.grafana-alloy = {
      enable = true;
      package = pkgs.grafana-alloy;
      environmentFile = config.age.secrets.grafana-alloy.path;
      configuration = ''
        prometheus.exporter.unix "local_metrics" {}

        discovery.relabel "relabel_prom" {
          targets = prometheus.exporter.unix.local_metrics.targets

          rule {
            target_label = "instance"
            replacement  = constants.hostname
          }

          rule {
            target_label = "job"
            replacement = "integrations/node_exporter"
          }
        }

        prometheus.scrape "local_prom" {
          scrape_interval = "10s"
          targets = discovery.relabel.relabel_prom.output
          forward_to = [ prometheus.relabel.relabel_prom2.receiver ]
        }

        prometheus.relabel "relabel_prom2" {
          forward_to = [ prometheus.remote_write.remote_prom.receiver ]

          rule {
            source_labels = ["__name__"]
            regex         = "node_scrape_collector_.+"
            action        = "drop"
          }
        }

        loki.source.journal "local_journald" {
          relabel_rules = discovery.relabel.relabel_loki.rules
          forward_to    = [ loki.write.remote_loki.receiver ]
        }

        discovery.relabel "relabel_loki" {
          targets = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }

          rule {
            source_labels = ["__journal__boot_id"]
            target_label  = "boot_id"
          }

          rule {
            source_labels = ["__journal__transport"]
            target_label  = "transport"
          }

          rule {
            source_labels = ["__journal_priority_keyword"]
            target_label  = "level"
          }
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
