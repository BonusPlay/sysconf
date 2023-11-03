{ config, ... }:
{
  # using cd-io instead of changedetection-io, because
  # some stuff has to be short (like interface names)

  custom.traefik = {
    enable = true;
    warpIP = "100.123.104.26";
    entries = [{
      name = "changedetection";
      domain = "cd.mlwr.dev";
      port = config.containers.cd-io.config.services.changedetection-io.port;
      entrypoints = [ "warps" ];
      target = config.containers.cd-io.extraVeths.side.localAddress;
    }];
  };

  containers.cd-io = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-neo";
    extraVeths.ve-cd = {
      hostAddress = "172.28.0.1";
      localAddress = "172.28.0.2";
    };

    config = { lib, ... }: {
      services.changedetection-io = {
        enable = true;
        webDriverSupport = true;
        listenAddress = "172.28.0.2";
        port = 4090;
        behindProxy = true;
        baseURL = "https://cd.mlwr.dev";
      };

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 4090 ];
        };
      };

      system.stateVersion = "23.05";
    };
  };
}
