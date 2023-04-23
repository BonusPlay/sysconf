{ lib, ... }:
let
  p4netConfig = (import ./p4net-config.nix);
in with p4netConfig;
{
  networking.firewall = {
    # BGP
    allowedTCPPorts = [ 179 ];
  };

  services.bird2 = {
    enable = true;
    config = let
      peerIPs = builtins.concatStringsSep ", " (lib.mapAttrsToList (_: peer: peer.linkIP + "/32") peers);
      mkProtocolEntry = name: peer: "protocol bgp ${name} from p4peers { neighbor ${peer.linkIP} as ${toString peer.ASN}; };";
      bgpPeerEntries = builtins.concatStringsSep "\n" (lib.mapAttrsToList mkProtocolEntry peers);
    in builtins.concatStringsSep "\n" [''
      define OWNAS =  65069;
      define OWNIP =  198.18.69.1;
      define OWNNETSET = [ 198.18.66.0/24+, 198.18.67.0/24+, 198.18.68.0/24+, 198.18.69.0/24+ ];
      define ALLSET = [ ${p4subnet}+ ];

      log syslog all;
      log stderr all;
      router id OWNIP;

      function is_self_net() {
        return net ~ OWNNETSET;
      }

      function is_valid_network() {
        return net ~ ALLSET;
      }

      protocol device {
        # recheck every 10 seconds
        scan time 10;
      }

      protocol kernel {
        scan time 20;
        learn;
        persist;
    
        ipv4 {
          import filter {
            if net ~ [ ${peerIPs} ] then accept;
            reject;
          };
          export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIP;
            accept;
          };
        };
      }

      protocol static {
        # Static routes to announce your own range(s)
        route 198.18.66.0/24 via "lo";
        route 198.18.67.0/24 via "lo";
        route 198.18.68.0/24 via "lo";
        route 198.18.69.0/24 via "lo";
        ipv4 {
          import all;
          export none;
        };
      };

      filter p4_input {
        if is_valid_network() && !is_self_net() then accept;
        reject;
      };

      filter p4_output {
        if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept;
        reject;
      };
      
      template bgp p4peers {
        local as OWNAS;
        path metric 1;
        multihop;
    
        ipv4 {
          import filter p4_input;
          export filter p4_output;
          import limit 1000 action block;
        };
      }
    '' bgpPeerEntries];
  };
}
