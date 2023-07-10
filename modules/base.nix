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
  };

  config = mkIf cfg.enable {
    nix = {
      gc.automatic = true;
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

    system.autoUpgrade = {
      enable = true;
      flake = "github:BonusPlay/sysconf";
      allowReboot = true;
    };

    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

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
