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

  networking.hostName = "bunker";
  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
