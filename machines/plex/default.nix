{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.device = "/dev/sda";

  custom = {
    base = {
      enable = true;
      autoUpgrade = false;
    };
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    podman.enable = true;
  };

  networking.hostName = "plex";

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vpl-gpu-rt ];
  };
}
