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
      buildMachines = [
        {
          system = "x86_64-linux";
          sshUser = "builder";
          sshKey = "/run/agenix/scv-key";
          maxJobs = 4;
          hostName = "scv.warp.lan";
          protocol = "ssh-ng"; # https://github.com/NixOS/nix/issues/2789#issuecomment-1868298547
        }
        {
          system = "aarch64-linux";
          sshUser = "bonus";
          maxJobs = 2;
          hostName = "kaldir.bonusplay.pl";
        }
      ];
      distributedBuilds = cfg.remoteBuild;
      settings.trusted-users = [ "@wheel" ];
    };

    age.secrets.scv-key = mkIf cfg.remoteBuild {
      file = ../secrets/scv-key.age;
    };

    system.autoUpgrade = {
      enable = cfg.autoUpgrade;
      flake = "github:BonusPlay/sysconf";
      allowReboot = cfg.allowReboot;
    };

    time.timeZone = mkDefault "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    # solves issue with splitdns cloudflare overwriting our custom DNS
    services.resolved = {
      enable = true;
      extraConfig = ''
        Cache=no-negative
      '';
    };

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
