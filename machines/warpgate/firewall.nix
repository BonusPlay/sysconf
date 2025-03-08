{ config, lib, ... }:
let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans ports;

  establishedRelated = "ct state { established, related } counter accept";
  mkVlanDefault = vlan: {
    name = vlan.name;
    value = {
      interfaces = [ vlan.name ];
      from = if vlan.internet then { wan = establishedRelated; } else {};
      masquerade = false;
    };
  };

  zones = lib.attrsets.recursiveUpdate (builtins.listToAttrs (map mkVlanDefault vlans)) ifaceConfig.zones;
  zonesWithoutLocal = lib.filterAttrs (name: _: name != "local") zones;
in
{
  #assertions = [
  #  {
  #    assertion = zones.local
  #    message = "local zone shouldn't have any interfaces";
  #  }
  #];
  networking.nftables = {
    enable = true;
    ruleset = let
      # Helper function to get interfaces for a zone
      getZoneInterfaces = zoneName: lib.concatStringsSep ", " (map (x: "\"${x}\"") zones.${zoneName}.interfaces);

      makeChain = fromZoneName: toZoneName: rules: ''
        chain ${fromZoneName}_to_${toZoneName} {
          ${rules}
        }
      '';
      makeJump = fromZoneName: toZoneName: _: ''
        iifname { ${getZoneInterfaces fromZoneName} } oifname { ${getZoneInterfaces toZoneName} } jump ${fromZoneName}_to_${toZoneName}
      '';

      iterZones = zones: func: lib.concatStrings (
        # { toZone.from = [...]; } => (toZone, { from = [...]; }
        lib.mapAttrsToList (fromZoneName: fromZone: (
          # from = { "a" = "rule"; } => (a, rules)
          lib.concatStrings (lib.mapAttrsToList (toZoneName: rules: (
            func fromZoneName toZoneName rules
          )) fromZone.from)
        )) zones
      );

      forwardZoneChains = iterZones zonesWithoutLocal makeChain;
      #forwardZoneJumps = iterZones zonesWithoutLocal makeJump;
      forwardZoneJumps = "";

      localChains = lib.concatStrings (lib.mapAttrsToList (fromZoneName: rules:
        makeChain fromZoneName "local" rules
      ) zones.local.from);
      localJumps = "";
      #localJumps = lib.concatStringsSep "\n" (lib.mapAttrsToList (fromZoneName: rules:
      #  "iifname { ${getZoneInterfaces fromZoneName} } jump ${fromZoneName}_to_local"
      #) zones.local.from);

      masqueradedZones = lib.attrNames (lib.filterAttrs(_: zone: zone.masquerade) zonesWithoutLocal);
      masqueradeRules = lib.concatStringsSep "\n" (
        map (zone: ''oifname { ${getZoneInterfaces zone} } masquerade'')
        masqueradedZones
      );
    in ''
      table inet filter {
        # Local zone chains (for input traffic to router)
        ${localChains}
        chain input {
          type filter hook input priority 0;
          policy drop;

          # Allow established/related connections
          ct state established,related accept

          # Allow loopback
          iifname "lo" accept

          # Jump to local zone chains
          ${localJumps}

          counter reject
        }

        # Forward zone chains (for traffic between zones)
        ${forwardZoneChains}

        chain forward {
          type filter hook forward priority 0;
          policy drop;

          # Allow established/related connections
          ct state established,related accept

          # Jump to forward zone chains based on input interface
          ${forwardZoneJumps}

          counter reject
        }
        chain output {
          type filter hook output priority 0;
          policy accept;
        }
      }

      table inet nat {
        chain prerouting {
          type nat hook prerouting priority 0;
        }
        chain postrouting {
          type nat hook postrouting priority 100;
          ${masqueradeRules}
        }
      }
    '';
  };
}
