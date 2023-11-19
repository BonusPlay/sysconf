{ config, lib, ... }:
{
  custom.traefik.entries = [
    {
      name = "radarr";
      domain = "radar.mlwr.dev";
      port = 7878;
      target = lib.strings.removeSuffix "/24" config.containers.radarr.extraVeths.ve-radarr.localAddress;
      entrypoints = [ "warps" ];
    }
  ];

  containers.radarr = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-radarr = {
      hostBridge = "br-arr";
      localAddress = "172.28.0.4/24";
    };
    bindMounts = {
      "/storage" = {
        hostPath = "/storage";
        isReadOnly = false;
      };
    };

    config = { lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];

      services.radarr = {
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
