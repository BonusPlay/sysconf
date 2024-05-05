{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
  ];

  # TODO: maybe tunnel via kaldir?

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    traefik = {
      enable = true;
      acmeDomains = [ "mlwr.dev" "bonusplay.pl" ];
      warpIP = "100.112.114.72";
      # we use cloudflared
      publicIP = "127.0.0.1";
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "bunker";
}
