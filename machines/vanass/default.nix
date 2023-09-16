{ lib, config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./mullvad.nix
  ];

  custom = {
    base = {
      enable = true;
      autoUpgrade = false;
    };
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = false;
  };

  boot = {
    loader.grub.device = "/dev/vda";
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}
