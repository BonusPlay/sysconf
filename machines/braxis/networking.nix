{ pkgs, ... }:
{
  networking = {
    hostName = "braxis";
    domain = "bonus.p4";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    dhcpcd.enable = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };

    interfaces.ens18 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "10.0.0.30";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.0.0.1";
        }];
      };
    };
  };
}
