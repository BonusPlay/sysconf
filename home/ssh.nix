{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = false;
    serverAliveInterval = 60;
    matchBlocks = {
      "crabdev" = {
        hostname = "crabdev-bios.warp.lan";
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
