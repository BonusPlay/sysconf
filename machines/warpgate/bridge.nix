let
  ifaceConfig = import ./interfaces.nix;
  inherit (ifaceConfig) vlans ports;

  vlanNetdevs = builtins.listToAttrs (map (vlan: {
    name = "${vlan.name}";
    value = {
      netdevConfig = {
        Name = vlan.name;
        Kind = "vlan";
      };
      vlanConfig = {
        Id = vlan.id;
        ParentDevice = "br0";
      };
    };
  }) vlans);

  vlanLinks = builtins.listToAttrs (map (port: {
    name = port.name;
    value = {
      matchConfig.MACAddress = port.mac;
      linkConfig.MasterDevice = {
        Name = port.name;
        MasterDevice = "br0";
      };
    };
  }) ports);
in {
  systemd.network = {
    networks.wan = {
      matchConfig.Name = "wan";
      networkConfig.DHCP = "ipv4";
    };

    links = {
      # rename wan interface
      "wan" = {
        matchConfig.MACAddress = "20:7c:14:f2:9b:cf";
        linkConfig.Name = "wan";
      };
    } // vlanLinks;

    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
      };
    } // vlanNetdevs;
  };
}
