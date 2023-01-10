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
              "198.18.66.10:9100"
            ];
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
