{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./sabnzbd.nix
    ./transmission.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    traefik = {
      enable = true;
      warpIP = "100.71.139.158";
    };
  };

  networking = {
    hostName = "moria";
    bridges.br-mullvad.interfaces = [ "enp6s19" ];
  };

  fileSystems."/storage" = {
    device = "glacius.mlwr.dev:/storage/moria";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };
}
