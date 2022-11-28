let
  p4netConfig = (import ./p4net-config.nix);

  # 1) split by "."
  #    "198.18.69.1" => [ "198" "18" "69" "1" ]
  # 2) take first 3 octets
  #    [ "198" "18" "69" "1" ] => [ "198" "18" "69" ]
  # 3) reverse list
  #    [ "198" "18" "69" ] => [ "69" "18" "198" ]
  # 4) join by "."
  #    [ "69" "18" "198" ] => "69.18.198"
  mkArpaAddr = ip: builtins.concatStringsSep "." (lib.reverseList (lib.take 3 (lib.splitString "." ip)));
  mkPeerEntry = name: peer: ''
    ${name}.p4 {
      forward . ${peer.linkIP}
    }

    ${mkArpaAddr peer.linkIP}.in-addr.arpa {
      forward . ${peer.linkIP}
    }

    bonus.p4 {
      file ${../../files/p4net/zone.conf}
    }
    69.18.198-in.addr.arpa {
      whoami
    }
  '';
  entries = pkgs.lib.mapAttrsToList mkPeerEntry p4netConfig.peers;
in with p4netConfig;
{
  services.coredns = {
    enable = true;
    config = ''
      ${entries}

      . {
          cache
      	errors
      }
    '';
  };
}
