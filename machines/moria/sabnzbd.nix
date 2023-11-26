{ config, lib, ... }:
{
  custom.traefik.entries = [
    {
      name = "sabnzbd";
      domain = "nzb.bonusplay.pl";
      port = 8080;
      target = lib.strings.removeSuffix "/24" config.containers.sabnzbd.extraVeths.ve-sabnzbd.localAddress;
      entrypoints = [ "warps" ];
    }
  ];

  containers.sabnzbd = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-sabnzbd = {
      hostBridge = "br-arr";
      localAddress = "172.28.0.2/24";
    };
    bindMounts = {
      "/storage" = {
        hostPath = "/storage/sabnzbd";
        isReadOnly = false;
      };
    };

    config = { lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];

      # TODO: this requires manual fix, as sabnzbd listens on 127.0.0.1
      # TODO: add FQDN to host_whitelist in config file
      services.sabnzbd.enable = true;

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
