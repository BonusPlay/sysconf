# https://github.com/vadika/nixos-config/blob/main/i915-iov.nix
{ config, pkgs, lib, ... }:
let
  #customKernel = pkgs.linux_6_6.override {
  #  structuredExtraConfig = with lib.kernel; {
  #    DRM_I915_PXP = yes;
  #    INTEL_MEI_PXP = module;
  #  };
  #};
  customKernel = pkgs.linux_latest.override {
    structuredExtraConfig = with lib.kernel; {
      DRM_I915_PXP = yes;
      INTEL_MEI_PXP = module;
    };
  };

  customKernelPackages = pkgs.linuxPackagesFor customKernel;

  i915SRIOVModule = customKernelPackages.callPackage ../../pkgs/i915-sriov-dkms.nix { kernel = customKernel; };
in
{
  boot.kernelPackages = customKernelPackages;
  boot.extraModulePackages = [ i915SRIOVModule ];

  # Blacklist the stock i915 module
  boot.blacklistedKernelModules = [ "i915" ];

  # Ensure our custom i915 module is loaded
  boot.kernelModules = [ "i915-sriov" ];
  boot.initrd.kernelModules = [ "i915-sriov" ];

    # Set up module loading order and options
  boot.extraModprobeConfig = ''
    alias i915 i915-sriov
  '';

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];

   # Rebuild module dependencies after boot
  boot.postBootCommands = ''
    /run/current-system/sw/bin/depmod -a ${customKernel.modDirVersion}
  '';
}
