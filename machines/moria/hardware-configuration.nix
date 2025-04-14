{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d4245aa3-16e7-4151-af83-cd2d78b3c6b7";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/d4245aa3-16e7-4151-af83-cd2d78b3c6b7";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/var/lib/arr-stack/downloads" =
    { device = "/dev/disk/by-uuid/869424d3-ea14-4e35-8217-be63e50c7fa3";
      fsType = "btrfs";
      options = [ "subvol=downloads" "noatime" ];
    };

  fileSystems."/storage" = {
    device = "glacius.internal:/storage";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
