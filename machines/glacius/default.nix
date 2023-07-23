{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./nfs.nix
    ./sabnzbd.nix
  ];

  custom = {
    base = {
      enable = true;
      allowReboot = false;
    };
    server = {
      enable = true;
      vm = false;
    };
    monitoring.enable = true;
    traefik = {
      enable = true;
      warpIP = "100.70.210.5";
      entries = [{
        name = "sabnzbd";
        domain = "nzb.mlwr.dev";
        port = 8080;
        entrypoints = [ "warpsecure" ];
      }];
    };
    warp-net.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    initrd = {
      availableKernelModules = [ "igc" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          hostKeys = [
            "/etc/initrd/ssh_host_rsa_key"
            "/etc/initrd/ssh_host_ed25519_key"
          ];
          authorizedKeys = [ (builtins.readFile ./../../files/yubi.ssh) ];
        };
      };
    };
  };

  services.btrfs.autoScrub.enable = true;
  services.fwupd.enable = true;
}
