{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.custom.base;
in
{
  options.custom.base = {
    enable = mkEnableOption "base configuration of Bonus's machines";
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings.trusted-users = [ "@wheel" ];
    };

    nixpkgs = {
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "olm-3.2.16"
          "python3.12-ecdsa-0.19.1"
        ];
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "corefonts"
        ];
      };
      overlays = import ../overlays inputs;
    };

    boot.tmp.cleanOnBoot = true;

    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    # solves issue with splitdns cloudflare overwriting our custom DNS
    services.resolved = {
      enable = true;
      llmnr = lib.mkDefault "false";
      extraConfig = ''
        Cache=no-negative
      '';
    };

    # harden openssh
    services.openssh.settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };

    # networkd + resolved
    systemd.network.enable = true;
    networking.dhcpcd.enable = false;
    networking.useDHCP = false;

    environment.systemPackages = with pkgs; [
      neovim
      wget
      tmux
      htop
      git
      iftop
      iotop
      rsync
    ];

    system.stateVersion = "24.05";
  };
}
