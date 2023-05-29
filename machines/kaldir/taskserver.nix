let
  port = 5070;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  containers.taskserver = {
    autoStart = true;

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

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
    };
  };
}
