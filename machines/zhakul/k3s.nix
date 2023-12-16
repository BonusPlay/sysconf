{ config, lib, ... }:
let
  containerIP = config.containers.k3s.extraVeths.ve-k3s.localAddress;
  k8sApiPort = 6443;
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
      domain = "artemis-dashboard.mlwr.dev";
      port = 9091;
      target = containerIP;
      entrypoints = [ "warps" ];
    }
    {
      name = "k8s-api";
      domain = "artemis-k3s.mlwr.dev";
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
      localAddress = "172.28.0.2";
      hostAddress = "172.28.0.1";
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
