{ config, ... }:
let
  port = config.containers.dockerRegistry.config.services.dockerRegistry.port;
in
{
  age.secrets.drUsersFile = {
    file = ../../secrets/docker-registry-users.age;
    mode = "0400";
    owner = "traefik";
  };

  custom.traefik.entries = [
    {
      name = "docker-registry";
      domain = "dr.bonusplay.pl";
      target = config.containers.dockerRegistry.localAddress;
      port = port;
      middlewares = [{
        drAuth.basicAuth.usersFile = config.age.secrets.drUsersFile.path;
      }];
      entrypoints = [ "webs" ];
    }
  ];

  containers.dockerRegistry = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.4.1";
    localAddress = "172.28.4.2";

    config = { config, pkgs, ... }: {
      services.dockerRegistry = {
        enable = true;
        listenAddress = "172.28.4.2";
        port = 4080;
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
