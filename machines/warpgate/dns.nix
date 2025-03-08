{ config, lib, ... }:
let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans;

  subnets = map (vlan: "192.168.${toString vlan.id}.0/24") vlans;
in
{
  services.powerdns = {
    enable = true;
    extraConfig = ''
      local-address=127.0.0.1
      local-port=5300
      launch=bind
    '';
  };

  services.pdns-recursor = {
    enable = true;
    dns.allowFrom = subnets ++ [ "127.0.0.0/8" ];
    forwardZones = {
      "warp.lan" = "127.0.0.1:5300";
      "klisie.pl" = "127.0.0.1:5300";
    };
  };

  # disable resolved as it would clash for the port
  services.resolved.enable = false;

  age.secrets = {
    klisie-zone = {
      file = ../../secrets/warpgate/klisie-pl-zone.age;
      mode = "0400";
      owner = "pdns";
    };
    warp-zone = {
      file = ../../secrets/warpgate/warp-lan-zone.age;
      mode = "0400";
      owner = "pdns";
    };
  };
}
