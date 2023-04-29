{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prom.bonus.p4/";
    # retentionTime = for the future
    port = 4050;
    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = [
              "198.18.66.1:${toString config.services.prometheus.exporters.node.port}"
              "198.18.66.1:${toString config.services.prometheus.exporters.bird.port}"
              "198.18.66.1:${toString config.services.prometheus.exporters.systemd.port}"
              "198.18.66.1:${toString config.services.prometheus.exporters.wireguard.port}"
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
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
      };
      bird = {
        enable = true;
        birdVersion = 2;
      };
      systemd = {
        enable = true;
      };
      wireguard = {
        enable = true;
        withRemoteIp = true;
      };
    };
  };
}
