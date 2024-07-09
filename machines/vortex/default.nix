{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./minio.nix
  ];

  custom = {
    base = {
      enable = true;
      allowReboot = false;
    };
    server = {
      enable = true;
      vm = true;
    };
    #monitoring.enable = true;
    warp-net.enable = true;
    caddy.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "vortex";
}
