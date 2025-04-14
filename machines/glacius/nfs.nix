{ lib, ... }:
{
  services.nfs.server = {
    enable = true;
    exports = let
      moria = "192.168.121.43(rw,sync,no_subtree_check,all_squash,anonuid=1250,anongid=1250)";
    in ''
      /storage/music     ${moria}
      /storage/movies    ${moria}
      /storage/tvshows   ${moria}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
