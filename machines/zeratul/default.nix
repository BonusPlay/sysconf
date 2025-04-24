{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./virtualisation.nix
    ./gaming.nix
    ./ctf.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
      timeout = 5;
    };
    initrd.kernelModules = [ "amdgpu" ];
#    kernelParams = [
#      "video=card2-DP-5:1920x1080@60" # DP monitor
#      "video=card1-HDMI-A-1:1920x1080@60" # kvm
#    ];
#    kernelModules = [ "lkrg" ];
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  services.openssh.enable = true;

  custom = {
    base = {
      enable = true;
      remoteBuild = false;
    };
    workstation = {
      enable = true;
      useWayland = false;
    };
    warp-net.enable = true;
  };
}
