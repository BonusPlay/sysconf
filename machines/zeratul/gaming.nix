{ pkgs, lib, ... }:
{
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    # apparently nvidia module still uses this on wayland
    videoDrivers = ["nvidia"];
    layout = "pl";
  };
}
