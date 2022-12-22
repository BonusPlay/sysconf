{
  services.prometheus.exporters = {
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
}
