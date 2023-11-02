{ config, ... }:
{
  custom.traefik.entries = [
    {
      name = "transmission";
      domain = "tpb.mlwr.dev";
      port = 9091;
      target = config.containers.transmission.extraVeths.ve-transmission.localAddress;
      entrypoints = [ "warps" ];
    }
  ];

  containers.transmission = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-transmission = {
      hostAddress = "172.28.1.1";
      localAddress = "172.28.1.2";
    };
    bindMounts = {
      "/storage" = {
        hostPath = "/storage/transmission";
        isReadOnly = false;
      };
    };

    config = { lib, ... }: {
      services.transmission = {
        enable = true;
        openPeerPorts = true;
        settings = {
          incomplete-dir-enabled = true;
          incomplete-dir = "/storage/incomplete";
          download-dir = "/storage/download";
          rpc-bind-address = "172.28.1.2";
          rpc-whitelist = "172.28.1.1";
          rpc-host-whitelist = "tpb.mlwr.dev";
        };
      };

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 9091 ];
        };
      };

      system.stateVersion = "23.05";
    };
  };
}
