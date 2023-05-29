{ pkgs, ... }:
{
  networking = {
    hostName = "vanass";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };

    nat = {
      enable = true;
      externalInterface = "wan";
      internalInterfaces = [ "warp-net" ];
    };

    interfaces = {
      "warp-net".ipv4 = {
        addresses = [{
          address = "10.20.31.11";
          prefixLength = 24;
        }];
      };
    };
  };
}
