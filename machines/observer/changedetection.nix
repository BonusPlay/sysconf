{ config, pkgs, lib, ... }:
{
  #services.changedetection-io = {
  #  enable = false;
  #  webDriverSupport = true;
  #  port = 4090;
  #  behindProxy = true;
  #  baseURL = "https://watch.warp.lan";
  #};

  #oci-containers.containers.changedetection-io-webdriver = {
  #  extraOptions = lib.mkForce [ "" ];
  #};

  systemd.services."podman-macvlan" = {
    description = "setup podman macvlan";
    after = [ "podman.service" ];
    wants = [ "podman.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.podman}/bin/podman network create \
        --driver=macvlan \
        -o parent=enp6s19 \
        mullvad_macvlan
    '';
  };

  virtualisation.oci-containers.containers.testing = {
    image = "selenium/standalone-chrome";
    environment = {
      VNC_NO_PASSWORD = "1";
      SCREEN_WIDTH = "1920";
      SCREEN_HEIGHT = "1080";
      SCREEN_DEPTH = "24";
    };
    volumes = [
      "/dev/shm:/dev/shm"
    ];
    extraOptions = [
      "--network=mullvad_macvlan"
    ];
  };

  #custom.caddy.entries = [
  #  {
  #    entrypoints = [ "100.67.16.58" ];
  #    domain = "change.warp.lan";
  #    target = removeSubnet cconf.extraVeths.ve-watch.localAddress;
  #    port = cconf.config.services.changedetection-io.port;
  #  }
  #];
}
