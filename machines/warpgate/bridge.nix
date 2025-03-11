{ lib, ... }:
let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans ports;

  sanity = {
    LinkLocalAddressing = "no";
    IPv6AcceptRA = "no";
    IPv6SendRA = "no";
    ConfigureWithoutCarrier = "yes";
    LLDP = "no";
    EmitLLDP = "no";
  };

  mkVlanNetdev = vlan: {
    name = "40-vlan-${vlan.name}";
    value = {
      netdevConfig = {
        Name = vlan.name;
        Kind = "vlan";
      };
      vlanConfig.Id = vlan.id;
    };
  };
  vlanNetdevs = builtins.listToAttrs(map mkVlanNetdev vlans);

  mkPortLink = port: {
    name = "20-port-${port.name}";
    value = {
      matchConfig.MACAddress = port.mac;
      linkConfig.Name = port.name;
    };
  };
  portLinks = builtins.listToAttrs(map mkPortLink ports);

  mkPortNetwork = port: {
    name = "30-port-${port.name}";
    value = {
      matchConfig.Name = port.name;
      networkConfig = {
        Bridge = "br0";
      } // sanity;
      linkConfig.RequiredForOnline = "no";
      bridgeVLANs = [
        {
          #PVID = lib.optional (port ? pvid) port.pvid;
          VLAN = port.vlans;
          # if not trunk, untag
          EgressUntagged = lib.mkIf (builtins.isInt port.vlans) port.pvid;
        }
      ];
    };
  };
  bridgePorts = builtins.filter (port: lib.hasAttr "bridge" port) ports;
  portNetworks = builtins.listToAttrs(map mkPortNetwork bridgePorts);

  mkVlanNetwork = vlan: {
    name = "50-vlan-${vlan.name}";
    value = {
      matchConfig.Name = vlan.name;
      networkConfig = {
        Bridge = vlan.bridge;
        Address = vlan.ip;
      } // sanity;
    };
  };
  vlanNetworks = builtins.listToAttrs(map mkVlanNetwork vlans);
in {
  systemd.network = {
    networks = {
      "10-br0" = {
        matchConfig.Name = "br0";
        linkConfig.RequiredForOnline = "no";
        networkConfig = sanity;
        vlan = map (vlan: vlan.name) vlans;
        bridgeVLANs = map (vlan: { VLAN = vlan.id; }) vlans;
      };
      "11-wan" = {
        matchConfig.Name = "sfp1-wan";
        networkConfig = {
          DHCP = "ipv4";
        } // sanity;
      };
    } // portNetworks // vlanNetworks;

    links = portLinks;

    netdevs = {
      "10-br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };

        bridgeConfig = {
          #DefaultPVID = "none";
          VLANFiltering = true;
          STP = false;
        };
      };
    } // vlanNetdevs;
  };
}
