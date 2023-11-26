{ config, lib, ... }:
{
  custom.traefik.entries = [
    {
      name = "prowlar";
      domain = "prowlar.bonusplay.pl";
      port = 9696;
      target = lib.strings.removeSuffix "/24" config.containers.prowlarr.extraVeths.ve-prowlarr.localAddress;
      entrypoints = [ "warps" ];
    }
  ];

  containers.prowlarr = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-prowlarr = {
      hostBridge = "br-arr";
      localAddress = "172.28.0.5/24";
    };

    config = { lib, ... }: {
      services.prowlarr = {
        enable = true;
        openFirewall = true;
      };

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall.enable = true;
      };

      system.stateVersion = "23.05";
    };
  };
}
