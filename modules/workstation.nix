{ config
, lib
, pkgs
, nixvim
, nix-index-database
, ... }:
with lib;
let
  cfg = config.custom.workstation;
in
{
  imports = [
    ./base.nix
    ./warp-net.nix
  ];

  options.custom.workstation = {
    enable = mkEnableOption "base configuration of Bonus's workstations";
    useWayland = mkOption {
      type = types.bool;
      default = true;
      description = "use sway or i3";
    };
  };

  config = mkIf cfg.enable {
    custom.base.autoUpgrade = false;

    # LET'S FUCKING GOOOO
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.systemd.enable = lib.mkDefault true;

    services.fwupd.enable = true;
    hardware.enableAllFirmware = true;
    hardware.graphics.enable = true;
    hardware.bluetooth.enable = true;

    time.timeZone = "Europe/Warsaw";
    i18n.defaultLocale = "en_US.UTF-8";

    services.printing.enable = true;

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;

    users.users.bonus = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "wireshark" "dialout" "adbusers" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      verbose = true;
      users.bonus = {
        imports = [
          ../home
          (if cfg.useWayland then ../home/sway.nix else ../home/i3.nix)
          nixvim.homeManagerModules.nixvim
          nix-index-database.hmModules.nix-index
        ];
        home.username = "bonus";
        home.homeDirectory = "/home/bonus";
        home.stateVersion = "24.05";
      };
    };

    virtualisation.libvirtd.qemu.vhostUserPackages = [ pkgs.virtiofsd ];

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

    programs.adb.enable = true;

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

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      dina-font
      #nerdfonts
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

      # Glasgow
      SUBSYSTEM=="usb", ATTRS{idVendor}=="20b7", ATTRS{idProduct}=="9db1", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="8613", TAG+="uaccess"
    '';
  };
}
