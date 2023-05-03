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

  # arion dependencies
  virtualisation = {
    docker.enable = true;
    #podman = {
    #  enable = true;
    #  dockerSocket.enable = true;
    #  dockerCompat = true;
    #  defaultNetwork.settings.dns_enabled = true;
    #};
  };

  services.qemuGuest.enable = true;
  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "22.11";
}
