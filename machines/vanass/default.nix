{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
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
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
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

  services.qemuGuest.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.05";
}
