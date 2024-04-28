{ lib, config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./grafana.nix
    ./matrix-synapse.nix
    ./matrix-meta.nix
    ./matrix-telegram.nix
    ./matrix-irc.nix
    ./matrix-slack.nix
    ./ghidra.nix
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
