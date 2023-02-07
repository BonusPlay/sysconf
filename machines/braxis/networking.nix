{ pkgs, ... }:
{
  networking = {
    hostName = "braxis";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
