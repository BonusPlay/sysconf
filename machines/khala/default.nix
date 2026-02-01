{ lib, config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./authelia.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "sso";
  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
