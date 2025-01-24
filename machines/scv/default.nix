{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
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

  users.users.builder = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIW4fcntwzJAlpncd1wH4Q565483eOWAX5nu298EKvt1" ];
  };

  networking.hostName = "scv";
}
