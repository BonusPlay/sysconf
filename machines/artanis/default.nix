{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./yubikey.nix
    ./firejail.nix
    ./zerotier.nix
    ./games.nix
    ./networking.nix
    ./virtualisation.nix
    ./development.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-substituters = https://cache.garnix.io
    extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
  '';

  # TODO: ping nixpkgs to not update every time
  # nix.registry.nixpkgs.flake = pkgs;
  # nix.nixPath = [ "nixpkgs=${pkgs}" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "32G";
  boot.kernelModules = [ "lkrg" ];

  services.fwupd.enable = true;
  services.tlp.enable = true;
  hardware.enableAllFirmware = true;
  hardware.opengl.enable = true;
  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

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
      home.stateVersion = "22.11";
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

  # smol hack, artanis doesn't run ssh server
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
  ];

  system.stateVersion = "22.11";
}
