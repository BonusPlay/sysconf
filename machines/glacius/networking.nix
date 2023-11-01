{ pkgs, ... }:
{
  networking = {
    hostName = "glacius";
    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
    nameservers = [ "1.1.1.1" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
    vlans.mullvad = {
      id = 60;
      interface = "enp2s0";
    };
    bridges.br-mullvad.interfaces = [ "mullvad" ];
  };
}
