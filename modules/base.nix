{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.base;
in
{
  options.custom.base = {
    enable = mkEnableOption "base configuration of Bonus's machines";
    stateVersion = mkOption {
      type = types.str;
      default = "24.05";
      description = "stateVersion to use";
    };
    autoUpgrade = mkOption {
      type = types.bool;
      default = false;
      description = "allow auto upgrade mechanism";
    };
    allowReboot = mkOption {
      type = types.bool;
      default = true;
      description = "allow reboot (in case of luks)";
    };
    remoteBuild = mkOption {
      type = types.bool;
      default = true;
      description = "use remote nix builders";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings.trusted-users = [ "@wheel" ];
    };

    system.autoUpgrade = {
      enable = cfg.autoUpgrade;
      flake = "github:BonusPlay/sysconf";
      allowReboot = cfg.allowReboot;
    };

    boot.tmp.cleanOnBoot = true;

    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    # solves issue with splitdns cloudflare overwriting our custom DNS
    services.resolved = {
      enable = true;
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

    environment.etc."ssl/certs/warp-net.crt".source = ../files/warp-net-root.crt;
    security.pki.certificateFiles = [ ../files/warp-net-root.crt ];

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

    system.stateVersion = cfg.stateVersion;
  };
}
