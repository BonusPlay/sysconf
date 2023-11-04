{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./keycloak.nix
    ./discord-bot.nix
    ./hedgedoc.nix
    ./taiga.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  networking.hostName = "braxis";

  virtualisation = {
    docker.enable = true;
    oci-containers.backend = "docker";
  };

  services.cloudflared.enable = true;
}
