{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./virtualisation.nix
    ./gaming.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    tmp = {
      tmpfsSize = "32G";
      useTmpfs = true;
    };
    kernelModules = [ "lkrg" ];
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  services.openssh.enable = true;

  custom.base.enable = true;
  custom.workstation.enable = true;
  custom.warp-net.enable = true;
}
