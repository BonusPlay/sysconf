{ config, pkgs, ... }:
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
}
