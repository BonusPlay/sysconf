{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ./docker-registry.nix
    ./grafana.nix
    ./matrix-synapse.nix
    ./matrix-meta.nix
    ./matrix-telegram.nix
    ./matrix-irc.nix
    ./matrix-googlechat.nix
    ./matrix-slack.nix
    ./mosquitto.nix
    ./ghidra.nix
    ./influx.nix
    ./nextcloud.nix
    ./hedgedoc.nix
    ./obsidian.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = false;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    traefik = {
      enable = true;
      acmeDomains = [ "mlwr.dev" "bonusplay.pl" ];
      publicIP = "10.0.0.131";
      warpIP = "100.98.118.66";
    };
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
  };

  services.fwupd.enable = true;
}
