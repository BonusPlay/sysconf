{ pkgs, ... }:
{
  networking = {
    hostName = "vanass";
    domain = "bonus.p4";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    dhcpcd.enable = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };

    nat = {
      enable = true;
      externalInterface = "wan";
      internalInterfaces = [ "p4net" ];
      internalIPs = [ "198.18.66.200" ];
    };

    defaultGateway = {
      address = "10.0.0.1";
      interface = "wan";
    };

    interfaces = {
      wan.ipv4 = {
        addresses = [{
          address = "10.0.0.20";
          prefixLength = 24;
        }];
      };
      p4net.ipv4 = {
        addresses = [{
          address = "198.18.67.10";
          prefixLength = 24;
        }];
        routes = [{
          address = "198.18.0.0";
          prefixLength = 24;
          via = "198.18.67.1";
        }];
      };
    };
  };
}
