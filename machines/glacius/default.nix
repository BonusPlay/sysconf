{ lib, config, pkgs, nixpkgs-unstable, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./tailscale.nix
    ./monitoring.nix
    ./nfs.nix
  ];

  nix = {
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:BonusPlay/sysconf";
    allowReboot = false;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    initrd = {
      availableKernelModules = [ "igc" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          hostKeys = [
            "/etc/initrd/ssh_host_rsa_key"
            "/etc/initrd/ssh_host_ed25519_key"
          ];
          authorizedKeys = [ (builtins.readFile ./../../files/yubi.ssh) ];
        };
      };
    };
  };

  services.btrfs.autoScrub.enable = true;
  services.fwupd.enable = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.bonus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    tmux
    htop
    git
  ];

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.05";
}
