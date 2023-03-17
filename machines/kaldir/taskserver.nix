let
  hostIP = "192.168.103.1";
  containerIP = "192.168.103.10";
  port = 5070;
in
{
  networking.nat = {
    forwardPorts = [
      {
        sourcePort = 5070;
        proto = "tcp";
        destination = "${containerIP}:${toString port}";
      }
    ];
  };

  containers.taskserver = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;

    config = { config, pkgs, ... }: {

      services.taskserver = {
        enable = true;
        listenHost = "0.0.0.0";
        listenPort = port;
        fqdn = "taskserver.bonusplay.pl";
        organisations.xakep.users = [ "bonus" ];
        pki.auto.expiration = {
          ca = 3650;
          client = 3650;
          crl = 3650;
          server = 3650;
        };
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
