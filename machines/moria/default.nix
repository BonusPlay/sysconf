{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    podman.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "moria";
  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };

  networking.firewall.allowedTCPPorts = [
    9091  # transmission
    7878  # radarr
    8989  # sonarr
    6767  # bazarr
    9696  # prowlarr
    5055  # overserr
    8080  # sabnzbd
    3333  # bitmagnet
  ];
}
