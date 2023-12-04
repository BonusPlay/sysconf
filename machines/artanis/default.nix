{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./games.nix
    ./networking.nix
    ./virtualisation.nix
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

  # can't really do much about it for now
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
  ];


  services.tlp.enable = true;

  custom.base.enable = true;
  custom.workstation.enable = true;
  custom.warp-net.enable = true;
}
