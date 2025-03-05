{ lib, ... }:
{
  services.nfs.server = {
    enable = true;
    exports = let
      plex = "192.168.6.20(rw,sync,no_subtree_check,all_squash,anonuid=1250,anongid=1250)";
    in ''
      /storage/music     ${plex}
      /storage/movies    ${plex}
      /storage/tvshows   ${plex}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
