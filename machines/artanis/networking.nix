{ config, pkgs, ... }:
{
  age.secrets.wifi = {
    file = ../../secrets/wifi.age;
    mode = "0440";
    group = "systemd-network";
  };

  # load passwords
  systemd.services.wpa_supplicant.serviceConfig.EnvironmentFile = "${config.age.secrets.wifi.path}";

  # use systemd-networkd
  systemd.network.enable = true;
  networking.dhcpcd.enable = false;

  systemd.network = {
    networks = {
      "wlp166s0" = {
        name = "wlp166s0";
        DHCP = "yes";
      };
      "wired" = {
        matchConfig = {
          MACAddress = "00:e0:4c:34:8d:eb";
        };
        DHCP = "yes";
      };
    };
  };

  networking = {
    hostName = "artanis";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    wireless = {
      enable = true;
      userControlled.enable = true;
      networks = {
        "@WIFI_1_NAME@".psk = "@WIFI_1_PASS@";
        "@WIFI_2_NAME@".psk = "@WIFI_2_PASS@";
        "@WIFI_3_NAME@".psk = "@WIFI_3_PASS@";
        "@WIFI_4_NAME@".psk = "@WIFI_4_PASS@";
        "@WIFI_5_NAME@" = {
          psk = "@WIFI_5_PASS@";
          hidden = true;
        };
        "@WIFI_6_NAME@".auth = ''
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="aklis@mion"
          password="@WIFI_6_PASS@"
        '';
        "@WIFI_7_NAME@".psk = "@WIFI_7_PASS@";
      };
    };
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
      extraCommands = ''
        iptables -P FORWARD DROP
      '';
    };
  };
}
