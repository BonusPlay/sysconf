{ config, lib, ... }:
{
  custom.traefik.entries = [
    {
      name = "plex";
      domain = "plex.bonusplay.pl";
      port = 32400;
      target = config.containers.plex.localAddress;
      entrypoints = [ "warps" ];
    }
  ];

  networking.nat.internalInterfaces = ["ve-plex"];

  containers.plex = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.1.1";
    localAddress = "172.28.1.2";
    bindMounts = {
      "/storage" = {
        hostPath = "/storage";
        isReadOnly = true;
      };
    };

    config = { nixpkgs, config, lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "plexmediaserver"
      ];

      services.plex = {
        enable = true;
        openFirewall = true;
      };

      networking.firewall.enable = true;
      system.stateVersion = "23.05";
    };
  };
}
