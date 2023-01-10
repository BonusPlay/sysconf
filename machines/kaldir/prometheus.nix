{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "prom.bonus.p4";
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
            labels = {
              alias = "kaldir.bonus.p4";
            };
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      bird = {
        enable = true;
        listenAddress = "127.0.0.1";
        birdVersion = 2;
      };
      systemd = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      wireguard = {
        enable = true;
        withRemoteIp = true;
        listenAddress = "127.0.0.1";
      };
    };
  };
}
