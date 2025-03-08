{ lib, ... }:
let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans ports;

  mkVlanNetdev = vlan: {
    name = "50-vlan-${vlan.name}";
    value = {
      netdevConfig = {
        Name = vlan.name;
        Kind = "vlan";
      };
      vlanConfig.Id = vlan.id;
    };
  };
  vlanNetdevs = builtins.listToAttrs(map mkVlanNetdev vlans);

  mkPortNetwork = port: {
    name = "50-port-${port.name}";
    value = {
      matchConfig.Name = port.name;
      networkConfig.Bridge = "br0";
      bridgeVLANs = [
        {
          PVID = port.pvid;
          EgressUntagged = port.pvid;
          VLAN = port.vlans;
        }
      ];
    };
  };
  bridgePorts = builtins.filter (port: lib.hasAttr "bridge" port) ports;
  portNetworks = builtins.listToAttrs(map mkPortNetwork bridgePorts);

  mkVlanNetwork = vlan: {
    name = "40-vlan-${vlan.name}";
    value = {
      matchConfig.Name = vlan.name;
      networkConfig = {
        Bridge = "br0";
        Address = vlan.ip;
      };
    };
  };
  vlanNetworks = builtins.listToAttrs(map mkVlanNetwork vlans);
in {
  systemd.network = {
    networks = {
      "10-br0" = {
        matchConfig.Name = "br0";
        linkConfig.RequiredForOnline = "routable";
      };
      "11-wan" = {
        matchConfig.Name = "wan";
        networkConfig.DHCP = "ipv4";
      };
    } // portNetworks // vlanNetworks;

    links = {
      # rename wan interface
      "wan" = {
        matchConfig.MACAddress = "20:7c:14:f2:9b:d0";

        linkConfig = {
          Name = "wan";
        };
      };
    };

    netdevs = {
      "10-br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };

        bridgeConfig = {
          DefaultPVID = 1;
          VLANFiltering = true;
        };
      };
    } // vlanNetdevs;
  };
}
