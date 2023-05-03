{ pkgs, ... }:
{
  networking = {
    hostName = "braxis";
    nameservers = [ "198.18.66.1" ];
    dhcpcd.enable = false;
    useDHCP = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };

    interfaces.ens18 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "198.18.68.20";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "198.18.68.1";
        }];
      };
    };
  };
}
