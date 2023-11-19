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
      hostBridge = "br-arr";
      localAddress = "172.28.0.3/24";
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
          rpc-bind-address = "172.28.0.3";
          rpc-whitelist = "172.28.0.*";
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
