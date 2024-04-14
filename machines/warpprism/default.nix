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
    warp-net = {
      enable = true;
      exitNode = true;
    };
    monitoring.enable = true;
  };

  services.tailscale.extraUpFlags = [
    "--advertise-routes=192.168.195.0/24"
  ];

  # do iptables nat here

  # mikrotik network
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "9e1948db634c148a" ];
  };

  system.activationScripts.bonus = let
    local = builtins.toJSON {
      settings = {
        interfacePrefixBlacklist = [ "br-" "docker0" ];
      };
    };
  in ''
    echo "9e1948db634c148a=mikrotik" >> /var/lib/zerotier-one/devicemap;
  '';

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "warpprism";
}
