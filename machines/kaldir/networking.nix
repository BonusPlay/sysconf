{ pkgs, ... }:
{
  networking = {
    hostName = "kaldir";
    #domain = "bonus.p4";
    useNetworkd = true;
    dhcpcd.enable = false;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
    nat = {
      enable = true;
      externalInterface = "enp0s3";
      internalInterfaces = ["ve-+"];
    };
    interfaces.enp0s3 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "10.0.0.131";
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

  services.nscd.enableNsncd = true;
}
