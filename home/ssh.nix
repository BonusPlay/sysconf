{
  programs.ssh = {
    enable = true;
    compression = true;
    hashKnownHosts = true;
    serverAliveInterval = 60;
    matchBlocks = {
      "ctf" = {
        hostname = "192.168.50.25";
        user = "xakep";
        identityFile = [ "/home/bonus/.ssh/id_ctfvm" ];
      };
      "chromium" = {
        hostname = "192.168.50.25";
        user = "xakep";
        identityFile = [ "/home/bonus/.ssh/id_ctfvm" ];
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "sudo machinectl shell xakep@chromium /bin/bash";
        };
      };
      "jc" = {
        hostname = "192.168.50.26";
        user = "xakep";
        identityFile = [ "/home/bonus/.ssh/id_jcvm" ];
      };
    };
  };
}
