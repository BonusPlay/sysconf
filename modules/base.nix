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
      default = "23.05";
      description = "stateVersion to use";
    };
    autoUpgrade = mkOption {
      type = types.bool;
      default = true;
      description = "allow auto upgrade mechanism";
    };
    allowReboot = mkOption {
      type = types.bool;
      default = true;
      description = "allow reboot (in case of luks)";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      gc.automatic = true;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    system.autoUpgrade = {
      enable = cfg.autoUpgrade;
      flake = "github:BonusPlay/sysconf";
      allowReboot = cfg.allowReboot;
    };

    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    # solves issue with splitdns cloudflare overwriting our custom DNS
    services.resolved.extraConfig = ''
      Cache=no-negative
    '';

    environment.systemPackages = with pkgs; [
      neovim
      wget
      tmux
      htop
      git
      iftop
      iotop
    ];

    system.stateVersion = cfg.stateVersion;
  };
}
