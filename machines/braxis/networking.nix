{ pkgs, ... }:
{
  networking = {
    hostName = "braxis";
    nameservers = [ "1.1.1.1" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
