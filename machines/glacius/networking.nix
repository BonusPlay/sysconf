{ pkgs, ... }:
{
  networking = {
    hostName = "glacius";
    nameservers = [ "1.1.1.1" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
