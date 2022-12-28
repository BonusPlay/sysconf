{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot = {
    loader.efi.canTouchEfiVariables = true;
    tmpOnTmpfs = true;
    cleanTmpDir = true;
    isContainer = true;
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
