{ config, pkgs, ... }:
{
  systemd.network.networks = {
    "10-sfp" = {
      matchConfig.Name = "enp3s0f0";
      networkConfig.DHCP = "yes";
    };
    "12-eth" = {
      matchConfig.Name = "enp0s31f6";
      networkConfig.DHCP = "yes";
    };
  };

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
