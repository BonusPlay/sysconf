{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device  = "local/root";
      fsType  = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/nix" =
    { device  = "local/nix";
      fsType  = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var" =
    { device  = "local/var";
      fsType  = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home" =
    { device  = "local/home";
      fsType  = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
