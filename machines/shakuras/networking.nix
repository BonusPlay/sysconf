{ pkgs, ... }:
{
  networking = {
    hostName = "shakuras";

    hosts = {
      "10.0.0.1" = [ "git.bonus.p4" ];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };

    interfaces = {
      # DMZ network
      ens18.useDHCP = true;

      # gitea runners bridge
      ens19 = {
        useDHCP = false;
        ipv4 = {
          addresses = [{
            address = "10.0.0.5";
            prefixLength = 24;
          }];
        };
      };
    };
  };
}
