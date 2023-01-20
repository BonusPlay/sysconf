{ pkgs, ... }:
{
  networking = {
    hostName = "shakuras";
    #domain = "bonus.p4";
    useNetworkd = true;
    dhcpcd.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };

  services.nscd.enableNsncd = true;
}
