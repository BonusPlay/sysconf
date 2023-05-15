{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./zerotier.nix
    ./traefik.nix
    ./gitea.nix
    ./monitoring.nix
  ];

  nix = {
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:BonusPlay/sysconf";
    allowReboot = true;
  };

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
    arion
  ];

  services.qemuGuest.enable = true;
  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "22.11";
}
