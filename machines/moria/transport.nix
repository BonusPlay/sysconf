{
  containers.transport = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-transpot = {
      hostAddress = "172.28.1.1";
      localAddress = "172.28.1.2";
    };

    config = { lib, ... }: {
      services.transmission = {
        enable = false;
      };

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 8080 ];
        };
      };

      system.stateVersion = "23.05";
    };
  };
}
