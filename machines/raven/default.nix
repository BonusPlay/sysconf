{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./step-ca.nix
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

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "raven";

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp0s18";
    networkConfig.DHCP = "yes";
  };
}
