{ config, lib, ... }:
{
  custom.traefik.entries = [
    {
      name = "plex";
      domain = "plex.bonusplay.pl";
      port = 32400;
      entrypoints = [ "warps" ];
    }
  ];

  containers.plex = {
    autoStart = true;
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

      networking = {
        interfaces.eth0.useDHCP = true;
        firewall.enable = true;
      };

      system.stateVersion = "23.05";
    };
  };
}
