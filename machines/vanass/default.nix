{ lib, config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./change-detection.nix
  ];

  custom = {
    base = {
      enable = true;
      autoUpgrade = true;
    };
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  networking = {
    hostName = "vanass";
    useDHCP = false;
    interfaces.enp6s18.useDHCP = true;
    bridges.br-neo.interfaces = [ "enp6s19" ];
  };
}
