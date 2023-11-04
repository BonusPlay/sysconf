{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./gitea-runner.nix
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
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "shakuras";
}
