{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/736ce10c-6308-4d31-bbbd-fa159a2ac69a";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/736ce10c-6308-4d31-bbbd-fa159a2ac69a";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/storage/minio" =
    { device = "/dev/disk/by-uuid/a9e95823-19db-4f0b-898a-205511bba56b";
      fsType = "btrfs";
      options = [ "subvol=minio" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
