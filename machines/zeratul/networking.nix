{ config, pkgs, ... }:
{
  systemd.network.enable = true;
  networking.dhcpcd.enable = false;

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
