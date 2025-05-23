{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./home-assistant.nix
    ./mosquitto.nix
    ./esphome.nix
    #./frigate.nix
    ./homebox.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nexus";

  systemd.network.networks = {
    "10-wan" = {
      matchConfig.Name = "enp6s18";
      networkConfig.DHCP = "yes";
    };
    "11-iot" = {
      matchConfig.Name = "enp6s19";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
      };
      dhcpV4Config.UseGateway = "no";
    };
  };
}
