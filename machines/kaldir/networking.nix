{ pkgs, ... }:
{
  networking = {
    hostName = "kaldir";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
    nat = {
      enable = true;
      externalInterface = "enp3s0";
    };
  };

  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp0s3";
      networkConfig = {
        Address = "10.0.0.131/24";
        Gateway = "10.0.0.1";
      };
    };
    "40-containers" = {
      matchConfig.Name = "ve-*";
      linkConfig.Unmanaged = true;
    };
  };
}
