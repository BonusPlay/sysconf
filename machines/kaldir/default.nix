{ lib, config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./chibisafe.nix
    ./mailcow.nix
    ./matrix-synapse.nix
    ./matrix-meta.nix
    ./matrix-telegram.nix
    ./matrix-irc.nix
    ./matrix-slack.nix
    ./ntfy.nix
    ./ghidra.nix
    ./obsidian.nix
    ./open-webui.nix
    ./uptime.nix
    ./beszel.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = false;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    caddy.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    tmp.useTmpfs = true;
  };

  services.fwupd.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    oci-containers.backend = "docker";
  };
}
