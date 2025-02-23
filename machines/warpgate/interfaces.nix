let
  vlans = [
    {
      id =  2;
      name = "guest";
      internet = true;
      ip = "192.168.2.1/24";
    }
    {
      id =  3;
      name = "iot";
      internet = false;
      ip = "192.168.3.1/24";
    }
    {
      id =  4;
      name = "dmz";
      internet = true;
      ip = "192.168.4.1/24";
    }
    {
      id =  5;
      name = "lan";
      internet = true;
      ip = "192.168.5.1/24";
    }
    {
      id =  9;
      name = "luks";
      internet = true;
      ip = "192.168.9.1/24";
    }
    {
      id = 10;
      name = "mgmt";
      internet = true;
      ip = "192.168.10.1/24";
    }
  ];
  ports = [
    {
      mac = "20:7c:14:f2:9b:d1";
      name = "zeratul";
      pvid = 10;
      vlans = 10;
      bridge = "br0";
    }
    {
      mac = "20:7c:14:f2:9b:d3";
      name = "switch-trunk";
      pvid = 1;
      vlans = [2 3 4 5 9 10];
      bridge = "br0";
    }
    {
      mac = "20:7c:14:f2:9b:cd";
      name = "capax-trunk";
      pvid = 1;
      vlans = [2 3 5 10];
      bridge = "br0";
    }
    {
      mac = "20:7c:14:f2:9b:cf";
      name = "wan";
    }
  ];
  zones = let
    establishedRelated = "ct state { established, related } counter accept";
    accept = "counter accept";
    localGenericRules = ''
      meta l4proto icmp counter accept

      # DHCP
      meta l4proto {tcp, udp} th dport 53 counter accept

      # DNS
      meta l4proto udp th dport 67 counter accept

      ${establishedRelated}
    '';
    wanFromRules = builtins.listToAttrs (map (vlan:
      {
        name = vlan.name;
        value = accept;
      }
    ) (builtins.filter (v: v.internet) vlans));
  in {
    iot.from = {
      lan   = accept;
      mgmt  = accept;
    };
    dmz.from = {
      mgmt  = accept;
    };
    lan.from = {
      mgmt  = accept;
    };
    mgmt.from = {
      guest = establishedRelated;
      iot   = establishedRelated;
      dmz   = establishedRelated;
    };
    local.from =  {
      wan   = establishedRelated;
      guest = localGenericRules;
      iot   = localGenericRules;
      dmz   = localGenericRules;
      lan   = localGenericRules;
      mgmt  = accept;
    };
    wan = {
      interfaces = [ "wan" ];
      from  = wanFromRules;
      masquerade = true;
    };
    backbone = {
      interfaces = [ "backbone" ];
      from = {};
      masquerade = true;
    };
    kncyber = {
      interfaces = [ "kncyber" ];
      from = {};
      masquerade = true;
    };
  };
in
{
  inherit vlans ports zones;
}
