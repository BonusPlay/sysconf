{ config, pkgs, lib, ... }:
{
  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;
  };
}
