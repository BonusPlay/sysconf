{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./k3s.nix
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
      warpIP = "";
      acmeDomains = [ "mlwr.dev" ];
    };
  };

  networking = {
    hostName = "zhakul";
    bridges.br-mullvad.interfaces = [ "enp6s19" ];
  };
}
