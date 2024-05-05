{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = false;
    serverAliveInterval = 60;
  };
}
