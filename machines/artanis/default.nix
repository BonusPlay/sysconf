{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services.tlp.enable = true;

  custom = {
    base = {
      enable = true;
      remoteBuild = false;
    };
    workstation = {
      enable = true;
      useWayland = true;
    };
    warp-net.enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      allowedBridges = [ "br-vms" "br-host" ];
    };
    spiceUSBRedirection.enable = true;
  };

  systemd.network.wait-online.ignoredInterfaces = [ "br-vms" "br-host" ];

  # required for VMs to use tunelling
  # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
  networking.firewall.checkReversePath = "loose";
}
