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
      daemon=yes
      log-common-errors=yes
      export-etc-hosts=n
      local-address=127.0.0.1
      local-port=5300
      launch=bind

      auth-zones=klisie.pl=${config.age.secrets.klisie-zone.path},warp.lan=${config.age.secrets.warp-zone.path}
    '';
  };

  services.pdns-recursor = {
    enable = true;
    dns.allowFrom = lib.concatStringsSep "," subnets;
    forwardZones = {
      "warp.lan" = "127.0.0.1:5300";
      "klisie.pl" = "127.0.0.1:5300";
    };
  };

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
