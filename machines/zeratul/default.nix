{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./virtualisation.nix
    ./gaming.nix
    ./ctf.nix
  ];

  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    kernelModules = [ "lkrg" ];
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  services.openssh.enable = true;

  # can't really do anything about this
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  custom = {
    base.enable = true;
    workstation = {
      enable = true;
      useWayland = false;
    };
    warp-net.enable = true;
  };
}
