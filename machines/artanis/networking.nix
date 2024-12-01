{ config, ... }:
{
  age.secrets.wifi = {
    file = ../../secrets/wifi.age;
    path = "/etc/wpa_supplicant.conf";
    owner = "root";
    group = "root";
    mode = "600";
  };

  # use systemd-networkd
  systemd.network.enable = true;
  networking.dhcpcd.enable = false;

  systemd.network = {
    networks = {
      "wlp166s0" = {
        name = "wlp166s0";
        DHCP = "yes";
      };
    };
  };

  networking = {
    hostName = "artanis";
    useNetworkd = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
