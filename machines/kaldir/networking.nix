{
  networking = {
    hostName = "kaldir";
    domain = "bonus.p4";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
    dhcpcd.enable = false;
    iproute2 = {
      enabled = true;
      rttablesExtraConfig = ''
        1 hive
      '';
    };
    interfaces.enp0s3 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "10.0.0.49";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.0.0.1";
        }];
      };
    };
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "10.0.2.10";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.0.2.1";
          options = {
            table = "hive";
          };
        }];
      };
    };
  };
}
