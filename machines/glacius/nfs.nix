{
  services.nfs.server = {
    enable = true;
    exports = ''
      /storage          10.20.30.0/24(rw,fsid=0,no_subtree_check) 10.20.31.0/24(rw,fsid=0,no_subtree_check) 10.20.30.0/24
      /storage/public   10.20.
      /storage/private  10.20.32.0/24
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
