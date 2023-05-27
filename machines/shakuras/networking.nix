{ pkgs, ... }:
{
  networking = {
    hostName = "shakuras";
    nameservers = [ "198.18.66.1" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
