{ config, lib, pkgs, ... }:
let
  initrd-key = "/root/glacius-initrd/ssh_host_ed25519_key";
in
{
  imports = [
    ./hardware-configuration.nix
    ./garage.nix
    ./nfs.nix
  ];

  boot = {
    kernelModules = [ "it87" ];
    kernelParams = [ "zfs.zfs_arc_max=${toString (26*1024*1024*1024)}" ];
    extraModulePackages = with config.boot.kernelPackages; [ it87 ];
    zfs.extraPools = [ "tank" ];
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [ "atlantic" ];
      availableKernelModules = [ "atlantic" ];
      secrets = {
        "${initrd-key}" = initrd-key;
      };
      network = {
        enable = true;
        ssh = {
          enable = true;
          hostKeys = [ initrd-key ];
          authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9QVoIP3xl7n+GwIUtN3A+IJreklf+pz7yJBQc17hn2MrEO0cXh3i6McHkHv7IiY0o/yDF7UvjaBqQAi84dpkX423Jiv7aGZKryOuUWZZ+1CRZ3q5PMhjR+J80tVa8q/uGnNXjE1Np6Ah7UAUqpbSx14TRydi+8sGuE3h+2Zujr4uGRORP7Eg7LmdSGg0pZEXm49IHfk6JnBRe0h8z3EGLoHroKU6pQBjKtHYWbxxqAsPfbF+NSlFgSp7RNKAtH0qtY/FgJJr2cTZxPv5/Ae0HaugNL1XxG2sPoPnrZ5S0PGRS5BBrK7fh5V/rgIIQLO3wDMzaiXrkHxQf2tuEMQrjf70GZRLDfCmF3ykz+H3j8WuWPgEXWqaf9N781SUS/Yr+KfA8DziAw6AOItKN3UuD2jGim9BF3K/5+fgQDt0t/RTgvarMOaC0fAVM1Wzo45H8aAbC1Q7p5DjPJdsWkzE3LuCQ6yYD+iTroUdyS9JaG6fs59f+nCjert8NqHM3fPbdu8kxBdqvR9Vfo8hwpnDp1HSry66cuoQhJ7/MZr1gznN3OnhA30nkrKi6ygCkJysC0xS+yLoNVKJvAe2oX0Jtn5UMhokvASobdvk3Eu1d28KctzPfYFHGIpwHAcSP2+SVLehveZxtAzVjXMxg3z+KFCWHozW5hbY/dQkv86q1uw=="];
        };
      };
      systemd = let
        # I know this is not the nix way, but all binaries are in path
        zfsUnlock = pkgs.writeShellScriptBin "zfs-unlock" ''
          zfs load-key local
          systemctl restart zfs-import-local.service
        '';
      in {
        enable = true;
        initrdBin = with pkgs; [ busybox zfsUnlock ];
        users.root.shell = "${zfsUnlock}/bin/zfs-unlock";
        network = {
          enable = true;
          networks."10-lan" = {
            matchConfig.Name = "enp5s0";
            networkConfig.DHCP = "yes";
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    lm_sensors
  ];

  custom = {
    base = {
      enable = true;
      autoUpgrade = false;
    };
    server = {
      enable = true;
      vm = false;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    caddy.enable = true;
  };

  systemd.network = {
    networks = {
      "10-eth" = {
        matchConfig.Name = "enp5s0";
        networkConfig = {
          VLAN = "lan";
          LinkLocalAddressing = "no";
          LLDP = "no";
          EmitLLDP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
          ConfigureWithoutCarrier = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "20-lan" = {
        matchConfig.Name = "lan";
        networkConfig.DHCP = "yes";
      };
    };
    netdevs."20-lan" = {
      netdevConfig = {
        Name = "lan";
        Kind = "vlan";
      };
      vlanConfig.Id = 5;
    };
  };

  networking.hostName = "glacius";
  networking.hostId = "06a43240";

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
