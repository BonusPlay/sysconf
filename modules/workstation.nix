{ config, lib, pkgs, nixpkgs-unstable, ... }:
with lib;
let
  cfg = config.custom.workstation;
in
{
  imports = [
    ./base.nix
    ./taskwarrior.nix
    ./warp-net.nix
  ];

  options.custom.workstation = {
    enable = mkEnableOption "base configuration of Bonus's workstations";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    services.fwupd.enable = true;
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
          ../home
        ];
        home.username = "bonus";
        home.homeDirectory = "/home/bonus";
        home.stateVersion = "23.05";
      };
    };

    environment.systemPackages = with pkgs; [
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

    # yubikey support
    programs.ssh.startAgent = false;
    services.pcscd.enable = true;

    services.udev.extraRules = ''
      # Intel FPGA Download Cable
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"

      # Intel FPGA Download Cable II
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"

      # ACS ACR1252U NFC Card Reader
      SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="223b", MODE="0666"
    '';
  };
}
