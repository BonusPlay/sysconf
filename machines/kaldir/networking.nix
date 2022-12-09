{ pkgs, ... }:
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
    #iproute2 = {
    #  enable = true;
    #  rttablesExtraConfig = ''
    #    1 khala
    #  '';
    #};

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

    #interfaces.enp1s0 = {
    #  useDHCP = false;
    #  ipv4 = {
    #    addresses = [{
    #      address = "10.0.2.10";
    #      prefixLength = 24;
    #    }];
    #    routes = [
    #      {
    #        address = "10.0.2.0";
    #        prefixLength = 24;
    #        options = {
    #          table = "khala";
    #        };
    #      }
    #      {
    #        address = "0.0.0.0";
    #        prefixLength = 0;
    #        via = "10.0.2.1";
    #        options = {
    #          table = "khala";
    #        };
    #      }
    #    ];
    #  };
    #};
  };

  #systemd.services.khalaPolicyRouting = {
  #  wantedBy = [ "network-online.target" ];
  #  after = [ "network-interfaces.target" ];
  #  description = "Add policy routing for khala interface";
  #  script = ''
  #    ${pkgs.iproute2}/bin/ip rule add from 10.0.2.10 lookup khala
  #    ${pkgs.iproute2}/bin/ip rule add from 10.0.2.1 lookup khala
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    RemainAfterExit = true;
  #  };
  #};
}
