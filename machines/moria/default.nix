{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./sabnzbd.nix
    ./transmission.nix
    ./radarr.nix
    ./prowlarr.nix
    ./plex.nix
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
      acmeDomains = [ "bonusplay.pl" ];
    };
  };

  networking = {
    hostName = "moria";
    bridges = {
      br-mullvad.interfaces = [ "enp6s19" ];
      br-arr.interfaces = [];
    };
    interfaces.br-arr.ipv4.addresses = [{
      address = "172.28.0.1";
      prefixLength = 24;
    }];
    nat = {
      enable = true;
      externalInterface = "enp6s18";
    };
  };

  fileSystems."/storage" = {
    device = "glacius.mlwr.dev:/storage/moria";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };
}
