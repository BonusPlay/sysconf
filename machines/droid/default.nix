{ lib, config, pkgs, home-manager, ... }:
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
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "droid";

  virtualisation.waydroid.enable = true;
}
