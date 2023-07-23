{
  networking.firewall.allowedTCPPorts = [];

  containers.sabnzbd = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.0.1";
    localAddress = "172.28.0.11";
    forwardPorts = [{
      containerPort = 80;
      hostPort = 8080;
      protocol = "tcp";
    }];

    config = { lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];

      services.sabnzbd = {
        enable = true;
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };

      system.stateVersion = "23.05";
    };
  };
}
