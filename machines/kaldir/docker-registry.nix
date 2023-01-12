let
  hostIP = "192.168.100.1";
  containerIP = "192.168.101.10";
  port = 4070;
in
{
  networking.nat.forwardPorts = [{
    destination = "${containerIP}:${toString port}";
    proto = "tcp";
    sourcePort = port;
  }];

  containers.mosquitto = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;

    config = { config, pkgs, ... }: {

      services.dockerRegistry = {
        enable = true;
        listenAddress = "0.0.0.0";
        port = port;
      };

      system.stateVersion = "22.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
      environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
    };
  };
}
