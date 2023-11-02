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
    useDHCP = false;
    interfaces.enp6s18.useDHCP = true;
    vlans.neo = {
      id = 20;
      interface = "enp6s18";
    };
    bridges.br-neo.interfaces = [ "neo" ];
  };
}
