{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./yubikey.nix
    ./zerotier.nix
    ./networking.nix
    ./virtualisation.nix
    ./development.nix
    ./gaming.nix
    ./tailscale.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      substituters = [
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    tmp = {
      tmpfsSize = "32G";
      useTmpfs = true;
    };
    kernelModules = [ "lkrg" ];
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;
  hardware.opengl.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  sound.enable = true;
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  users.users.bonus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "wireshark" "dialout" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nixpkgs-unstable; };
    users.bonus = {
      imports = [
        ../../home
      ];
      home.username = "bonus";
      home.homeDirectory = "/home/bonus";
      home.stateVersion = "23.05";
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    tmux
    htop
    iotop
    iftop
    sbctl
  ];

  # why is sudo so bloated
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "bonus" ];
      keepEnv = true;
      persist = true;
    }];
  };
  security.sudo.enable = false;

  programs.wireshark.enable = true;

  # smol hack, zeratul doesn't run ssh server
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  # needed for swaylock to register in pam
  programs.sway.enable = true;
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    dina-font
    nerdfonts
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
    unifont
    source-code-pro
    corefonts
  ];

  system.stateVersion = "23.05";
}
