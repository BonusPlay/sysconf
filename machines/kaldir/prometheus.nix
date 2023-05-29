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
              "kaldir.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
              "kaldir.mlwr.dev:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "kaldir";
          }
          {
            targets = [
              "gate.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
            ];
            labels.host = "warpgate";
          }
          {
            targets = [
              "zero.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
            ];
            labels.host = "zero";
          }
          {
            targets = [
              "endion.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
              "endion.mlwr.dev:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "endion";
          }
          {
            targets = [
              "shakuras.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
              "shakuras.mlwr.dev:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "shakuras";
          }
          {
            targets = [
              "vanass.mlwr.dev:${toString config.services.prometheus.exporters.node.port}"
              "vanass.mlwr.dev:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels.host = "vanass";
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
