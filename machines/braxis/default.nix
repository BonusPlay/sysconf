{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./keycloak.nix
    ./discord-bot.nix
    ./hedgedoc.nix
    ./cloudflared.nix
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot = {
    loader.grub.device = "/dev/sda";
    tmpOnTmpfs = true;
    cleanTmpDir = true;
  };

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
