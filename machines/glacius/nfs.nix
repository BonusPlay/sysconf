{ lib, ... }:
{
  services.nfs.server = {
    enable = true;
    exports = let
      subnets = [ "100.64.0.0/10" "192.168.5.0/24" "192.168.10.0/24" ];
      line = builtins.concatStringsSep " " (builtins.map (x: x + "(rw,sync,no_subtree_check)"));
    in ''
      /storage/general  ${line}
      /storage/backups  ${line}
      /storage/vms      192.168.10.10(rw,async,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
