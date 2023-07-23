{
  containers.sabnzbd = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.0.1";
    localAddress = "172.28.0.11";
    forwardPorts = [{
      containerPort = 8080;
      hostPort = 8080;
      protocol = "tcp";
    }];

    config = { lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];

      # TODO: this requires manual fix, as sabnzbd
      # listens on 127.0.0.1
      services.sabnzbd.enable = true;

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 8080 ];
      };

      system.stateVersion = "23.05";
    };
  };
}
