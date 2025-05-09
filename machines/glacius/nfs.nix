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
      /storage/backups   192.168.10.200(rw,sync,no_subtree_check,all_squash,anonuid=1249,anongid=1249)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
