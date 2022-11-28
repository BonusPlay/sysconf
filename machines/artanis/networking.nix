{ config, pkgs, ... }:
{
  age.secrets.wifi = {
    file = ../../secrets/wifi.age;
    mode = "0440";
    group = "systemd-network";
  };

  # load passwords
  systemd.services.wpa_supplicant.serviceConfig.EnvironmentFile = "${config.age.secrets.wifi.path}";

  networking = {
    hostName = "artanis";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # TODO: use systemd-networkd
    #dhcpcd.enable = false;

    wireless = {
      enable = true;
      userControlled.enable = true;
      networks = {
        ":)".psk = "@WIFI_1_PASS@";
        "BonusSpot".psk = "@WIFI_2_PASS@";
        "klisie".psk = "@WIFI_3_PASS@";
        "Galaxy S20 FE31E6".psk = "@WIFI_4_PASS@";
        "WEiTI".auth = ''
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="aklis@mion"
          password="@WIFI_5_PASS@"
        '';
        "stm-guest" = {
          psk = "@WIFI_6_PASS@";
          hidden = true;
        };
      };
    };
    firewall = {
      allowedTCPPorts = [ 13337 ];
      allowedUDPPorts = [ 13337 ];
    };
  };
}
