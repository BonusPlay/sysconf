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
      threads=1
      allow-from=${lib.concatStringsSep "," subnets}
      log-common-errors=yes
      non-local-bind=yes
      export-etc-hosts=n
      local-port=53
      recursor=1.1.1.1
      launch=bind

      auth-zones=klisie.pl=${config.age.secrets.klisie-zone.path},warp.lan=${config.age.secrets.warp-zone.path}
    '';
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
