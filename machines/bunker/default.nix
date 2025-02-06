{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./collabora.nix
    ./nextcloud.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    nginx.enable = true;
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "bunker";
  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
