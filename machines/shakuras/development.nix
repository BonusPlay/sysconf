{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    picocom
  ];
}
