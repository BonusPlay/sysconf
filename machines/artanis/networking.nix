{ config, ... }:
{
  age.secrets.wifi = {
    file = ../../secrets/wifi.age;
    path = "/etc/wpa_supplicant.conf";
    owner = "root";
    group = "root";
    mode = "600";
  };

  systemd.network.networks = {
    "10-wifi" = {
      matchConfig.Name = "wlp166s0";
      networkConfig.DHCP = "yes";
    };
    "11-wired" = {
      matchConfig.Name = "enp0s13f0u3";
      networkConfig.DHCP = "yes";
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
