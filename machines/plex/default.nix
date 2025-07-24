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
  };

  networking.hostName = "plex";

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vpl-gpu-rt ];
  };

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
