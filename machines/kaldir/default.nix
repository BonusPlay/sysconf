{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./docker-registry.nix
    ./grafana.nix
    ./hardware-configuration.nix
    ./loki.nix
    ./networking.nix
    ./p4net-bird.nix
    ./p4net-coredns.nix
    ./p4net-wg.nix
    ./p4net-zerotier.nix
    ./prometheus.nix
    ./seafile.nix
    ./traefik.nix
    ./matrix-synapse.nix
    ./matrix-facebook.nix
    ./matrix-telegram.nix
    ./mosquitto.nix
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 5;
    tmpOnTmpfs = true;
    cleanTmpDir = true;
  };

  services.fwupd.enable = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.bonus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    tmux
    htop
    git
  ];

  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;
  system.autoUpgrade.flake = "github:BonusPlay/sysconf";
  system.autoUpgrade.enable = true;

  system.stateVersion = "22.11";
}
