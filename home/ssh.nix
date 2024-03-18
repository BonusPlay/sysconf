{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = true;
    serverAliveInterval = 60;
    matchBlocks = {
      "ctf" = {
        hostname = "ctf";
        user = "xakep";
      };
    };
  };
}
