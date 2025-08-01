{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f923e4d5-888e-45bc-a6e0-144dd29fcb2c";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/f923e4d5-888e-45bc-a6e0-144dd29fcb2c";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/opt/arr/downloads" =
    { device = "/dev/disk/by-uuid/929d9c77-deee-430a-b81b-ba83900d1e62";
      fsType = "btrfs";
      options = [ "subvol=downloads" "noatime" ];
    };

  fileSystems."/opt/arr/bitmagnet/postgres" =
    { device = "/dev/disk/by-uuid/929d9c77-deee-430a-b81b-ba83900d1e62";
      fsType = "btrfs";
      options = [ "subvol=bitmagnet" "noatime" ];
    };

  fileSystems."/storage" = {
    device = "glacius.internal:/storage";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
