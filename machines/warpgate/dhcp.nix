{ config, lib, pkgs, ... }:
let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans;

  mkSubnetConfig = vlan: {
    id = vlan.id;
    pools = [{ pool = "192.168.${toString vlan.id}.100-192.168.${toString vlan.id}.199"; }];
    subnet = "192.168.${toString vlan.id}.0/24";
    option-data = [
      {
        name = "routers";
        data = "192.168.${toString vlan.id}.1";
      }
      {
        name = "domain-name-servers";
        data = "192.168.${toString vlan.id}.1";
      }
    ];
  };
  keaSettings = {
    Dhcp4 = {
      interfaces-config = {
        interfaces = map (x: x.name) vlans;
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      valid-lifetime = 4000;

      # assume global reservations
      reservations-global = true;
      # assume no reservations per-subnet (only global)
      reservations-in-subnet = false;
      # assume reservations only out of dhcp pool
      reservations-out-of-pool = true;
      # assume reservations using mac-address
      host-reservation-identifiers = [ "hw-address" ];

      # subnet configs
      subnet4 = map mkSubnetConfig vlans;
    };
  };

  settingsJson = builtins.toJSON keaSettings;
  # include file from secrets
  #templateString = ''<?include "${config.age.secrets.dhcp-reservations.path}"?>'';
  #finalConfig = builtins.substring 0 (builtins.stringLength settingsJson - 1) settingsJson + ",${templateString}}";
  finalConfig = settingsJson;
in
{
  services.kea.dhcp4 = {
    enable = true;
    configFile = pkgs.writeText "kea-dhcp4.conf" finalConfig;
  };

  age.secrets.dhcp-reservations = {
    file = ../../secrets/warpgate/dhcp-reservations.age;
    mode = "0400";
    owner = "root";
  };
}
