{ pkgs, ... }:
{
  networking = {
    hostName = "redstone";
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
