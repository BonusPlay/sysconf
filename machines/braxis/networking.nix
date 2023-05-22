{ pkgs, ... }:
{
  networking = {
    hostName = "braxis";
    nameservers = [ "1.1.1.1" ];
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
          address = "192.168.4.10";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "192.168.4.1";
        }];
      };
    };
  };
}
