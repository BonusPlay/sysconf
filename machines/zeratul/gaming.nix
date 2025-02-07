{ config, pkgs, lib, ... }:
{
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    gsp.enable = config.hardware.nvidia.open;
    nvidiaSettings = true;
    # https://github.com/NixOS/nixpkgs/issues/375730#issuecomment-2625157971
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.86.16";
      sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
      openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
      settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
      usePersistenced = false;
    };
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    # apparently nvidia module still uses this on wayland
    videoDrivers = ["nvidia"];
    xkb.layout = "pl";
  };

  environment.sessionVariables = {
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  boot = {
    kernelParams = [
      "nvidia.NVreg_UsePageAttributeTable=1"       # why this isn't default is beyond me.
      "nvidia_modeset.disable_vrr_memclk_switch=1" # stop really high memclk when vrr is in use.
    ];
    blacklistedKernelModules = ["nouveau"];
  };

  programs.gamemode.enable = true;
}
