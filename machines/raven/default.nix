{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./step-ca.nix
    ./step-ca-module.nix
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

  networking.hostName = "raven";

  environment.systemPackages = with pkgs; [ opensc openssl usbutils ];

  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp6s18";
      networkConfig.DHCP = "yes";
    };
  };
}
