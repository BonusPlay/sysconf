{ config, ... }:
{
  custom.traefik.entries = [
    {
      name = "hedgedoc";
      domain = "md.bonusplay.pl";
      target = config.containers.hedgedoc.localAddress;
      port = config.containers.hedgedoc.config.services.hedgedoc.settings.port;
      entrypoints = [ "webs" ];
    }
  ];

  containers.hedgedoc = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.103.1";
    localAddress = "192.168.103.2";

    config = { config, pkgs, ... }: {
      services.hedgedoc = {
        enable = true;
        settings = {
          db = {
            dialect = "sqlite";
            storage = "/var/lib/hedgedoc/db.hedgedoc.sqlite";
          };
          domain = "md.bonusplay.pl";
          protocolUseSSL = true;

          # for some reason hedgedoc binds on "localhost"
          # but in the end only listens for IPv6, wtf
          host = "192.168.103.2";

          # enable email login
          email = true;
          # disable email signup
          allowEmailRegister = false;

          # security
          allowFreeURL = false;
          allowAnonymousEdits = false;
          allowAnonymous = false;
          defaultPermission = "limited";
          requireFreeURLAuthentication = true;

          documentMaxLength = 10000000;
        };
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ config.services.hedgedoc.settings.port ];
      };
    };
  };
}
