{ config, pkgs, ... }:
{
  systemd.network.enable = true;
  networking.dhcpcd.enable = false;

  networking = {
    hostName = "zeratul";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
      extraCommands = ''
        iptables -P FORWARD DROP
      '';
    };
  };
}
