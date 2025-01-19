{
  services.frigate = {
    enable = true;
    hostname = "frigate.warp.lan";
    settings = {
      mqtt = {
        enabled = true;
        host = "127.0.0.1";
      };
      cameras = {
        dummy_camera = {
          enabled = false;
          ffmpeg.inputs = [{ path = "rtsp://127.0.0.1:554/rtsp"; roles = [ "detect" ]; }];
        };
      };
    };
  };

  custom.nginx.entries = [
    {
      entrypoints = [ "100.84.139.31" ];
      domain = "frigate.warp.lan";
      # no target/port, as module already does that, this is mostly for TLS
      target = null;
      port = null;
    }
  ];

  # secret env vars
  #systemd.services.frigate.serviceConfig.EnvironmentFile = cfg.environmentFile;
}
