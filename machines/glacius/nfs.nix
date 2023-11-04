{ lib, ... }:
{
  services.nfs.server = {
    enable = true;
    exports = let
      subnets = [ "100.64.0.0/10" "192.168.5.0/24" "192.168.10.0/24" ];
      line = builtins.concatStringsSep " " (builtins.map (x: x + "(rw,sync,no_subtree_check,all_squash)") subnets);
    in ''
      /storage/general ${line}
      /storage/backups ${line}
      /storage/moria   ${line}
      /storage/proxmox 100.64.0.0/10(rw,async,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
