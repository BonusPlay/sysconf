{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = false;
    serverAliveInterval = 60;
    matchBlocks = {
      "crabdev-bios" = {
        hostname = "crabdev-bios.warp.lan";
        user = "a";
        identitiesOnly = true;
        identityFile = [ "/home/bonus/.ssh/id_crabdev" ];
      };
      "crabdev-uefi" = {
        hostname = "crabdev-uefi.warp.lan";
        user = "a";
        identitiesOnly = true;
        identityFile = [ "/home/bonus/.ssh/id_crabdev" ];
      };
      "ctf" = {
        hostname = "ctf.warp.lan";
        user = "xakep";
        identitiesOnly = true;
        identityFile = [ "/home/bonus/.ssh/id_ctf" ];
      };
    };
  };
}
