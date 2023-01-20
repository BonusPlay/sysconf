{ config, pkgs, lib, ... }:
{
  imports = [
    ./networking.nix
    ./p4net.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    cleanTmpDir = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # A lot GUI programs need this, nearly all wayland applications
        "cma=128M"
    ];
    loader = {
      raspberryPi = {
        enable = true;
        version = 4;
      };
      grub.enable = false;
    };
  };

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    tmux
    wget
    git
    htop
    iotop
    iftop
  ];

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  users.users.bonus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "22.11";
}
