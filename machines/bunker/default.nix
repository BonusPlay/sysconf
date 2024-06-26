{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
    ./onlyoffice.nix
  ];

  # TODO: maybe tunnel via kaldir?

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    caddy.enable = true;
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking = {
    hostName = "bunker";
    useDHCP = false;
    bridges.br-docs.interfaces = [];
    interfaces = {
      enp6s18.useDHCP = true;
      br-docs.ipv4.addresses = [
        {
          address = "172.28.0.1";
          prefixLength = 24;
        }
      ];
    };
  };
}
