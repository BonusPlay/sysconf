{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prom.mlwr.dev/";
    # retentionTime = for the future
    port = 4050;
    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = [
              "198.18.66.1:${toString config.services.prometheus.exporters.node.port}"
              "198.18.66.1:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "kaldir";
          }
          {
            targets = [
              "198.18.66.5:${toString config.services.prometheus.exporters.node.port}"
            ];
            labels.host = "warpgate";
          }
          {
            targets = [
              "198.18.66.10:${toString config.services.prometheus.exporters.node.port}"
            ];
            labels.host = "zero";
          }
          {
            targets = [
              "198.18.66.100:${toString config.services.prometheus.exporters.node.port}"
              "198.18.66.100:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "endion";
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
      };
      systemd = {
        enable = true;
      };
    };
  };
}
