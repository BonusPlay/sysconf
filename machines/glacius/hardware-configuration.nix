{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/db52a00e-dfa8-4975-af70-0ac97826861a";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" ];
  };

  boot.initrd.luks.devices."crypt-root".device = "/dev/disk/by-uuid/dbf4b4f7-c28d-4dd9-a433-160a6027ee9f";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/db52a00e-dfa8-4975-af70-0ac97826861a";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/16BD-F74E";
    fsType = "vfat";
  };

  # decrytped using crypttab
  fileSystems."/storage/general" = {
    device = "/dev/disk/by-uuid/0c220e47-fb07-404b-b035-cf79a3bdce30";
    fsType = "btrfs";
    options = [ "subvol=general" "compress=zstd" ];
  };

  fileSystems."/storage/backups" = {
    device = "/dev/disk/by-uuid/0c220e47-fb07-404b-b035-cf79a3bdce30";
    fsType = "btrfs";
    options = [ "subvol=backups" "compress=zstd" ];
  };

  fileSystems."/storage/vms" = {
    device = "/dev/disk/by-uuid/0c220e47-fb07-404b-b035-cf79a3bdce30";
    fsType = "btrfs";
    options = [ "subvol=vms" "compress=zstd" "noatime" ];
  };

  environment.etc.crypttab = {
    text = ''
      crypt-sda UUID=a58b6d4a-3123-4b51-92d8-8dfe67d6fa5c /etc/luksKey luks,noearly,discard
      crypt-sdb UUID=5210d1d9-dddf-404b-b5fb-fda99c79cf99 /etc/luksKey luks,noearly,discard
    '';
    mode = "0444";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
