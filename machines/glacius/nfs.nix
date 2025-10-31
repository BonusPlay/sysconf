{ lib, ... }:
{
  services.nfs.server = {
    enable = true;
    exports = let
      moria = "192.168.121.43(rw,sync,no_subtree_check,all_squash,anonuid=1250,anongid=1250)";
      plex = "192.168.126.45(ro,sync,no_subtree_check,all_squash,anonuid=1250,anongid=1250)";
      zeratul = "192.168.10.200(rw,sync,no_subtree_check,all_squash,anonuid=1249,anongid=1249)";
    in ''
      /storage/music     ${moria} ${plex}
      /storage/movies    ${moria} ${plex}
      /storage/tvshows   ${moria} ${plex}
      /storage/backups   ${zeratul}
      /storage/warez     ${zeratul}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
