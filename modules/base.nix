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
      settings = {
        substituters = [
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:BonusPlay/sysconf";
      allowReboot = cfg.allowReboot;
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
