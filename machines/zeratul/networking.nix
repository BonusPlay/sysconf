{ config, pkgs, ... }:
{
  systemd.network.networks = {
    "10-sfp" = {
      matchConfig.Name = "enp9s0";
      networkConfig.DHCP = "yes";
    };
    "11-eth" = {
      matchConfig.Name = "enp8s0";
      networkConfig.DHCP = "yes";
    };
  };

  systemd.network.wait-online.ignoredInterfaces = [ "enp8s0" ];

  networking = {
    hostName = "zeratul";
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
      extraCommands = ''
        iptables -P FORWARD DROP
      '';
    };
  };
}
