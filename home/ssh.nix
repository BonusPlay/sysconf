{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = true;
    serverAliveInterval = 60;
  };
}
