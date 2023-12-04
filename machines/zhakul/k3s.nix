{ config, lib, ... }:
let
  containerIP = lib.strings.removeSuffix "/24" config.containers.k3s.extraVeths.ve-k3s.localAddress;
  k8sApiPort = lib.toInt lib.last (lib.strings.split ":" config.containers.k3s.config.services.k3s.serverAddr);
  artemisPort = 5000;
  dashboardPort = 5001;
in
{
  custom.traefik.entries = [
    {
      name = "artemis";
      domain = "artemis.mlwr.dev";
      port = 9091;
      target = containerIP;
      entrypoints = [ "warps" ];
    }
    {
      name = "dashboard";
      domain = "dashboard.artemis.mlwr.dev";
      port = 9091;
      target = containerIP;
      entrypoints = [ "warps" ];
    }
    {
      name = "k8s-api";
      domain = "k3s.artemis.mlwr.dev";
      port = k8sApiPort;
      target = containerIP;
      entrypoints = [ "warps" ];
    }
  ];

  containers.k3s = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-k3s = {
      localAddress = "172.28.0.2/24";
      hostAddress = "172.28.0.1/24";
    };
    config = { lib, ... }: {
      services.k3s = {
        enable = true;
        disableAgent = true;
      };

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ k8sApiPort artemisPort dashboardPort ];
        };
      };

      system.stateVersion = "23.05";
    };
  };
}
