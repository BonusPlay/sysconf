{ config, ... }:
{
  custom.traefik = {
    enable = true;
    warpIP = "100.123.104.26";
    entries = [{
      name = "changedetection";
      domain = "cd.mlwr.dev";
      port = config.containers.changedetection-io.config.services.changedetection-io.port;
      entrypoints = [ "warps" ];
      target = config.containers.changedetection-io.extraVeths.side.localAddress;
    }];
  };

  containers.changedetection-io = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-neo";
    extraVeths.side = {
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
