{ config, ... }:
let
  cconf = config.containers.changedetection;
  removeSubnet = ipWithSubnet: builtins.head (builtins.split "/" ipWithSubnet);
in
{
  custom.caddy.entries = [
    {
      entrypoints = [ "100.67.16.58" ];
      domain = "change.warp.lan";
      target = removeSubnet cconf.extraVeths.ve-watch.localAddress;
      port = cconf.config.services.changedetection-io.port;
    }
  ];

  containers.changedetection = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-watch = {
      hostAddress = "172.28.0.1";
      localAddress = "172.28.0.2";
    };

    config = { config, pkgs, lib, ... }: {
      services.changedetection-io = {
        enable = true;
        webDriverSupport = true;
        port = 4090;
        behindProxy = true;
        baseURL = "https://change.warp.lan";
      };

      # workaround
      virtualisation.containers.containersConf.settings.containers.keyring = false;

      networking = {
        interfaces.eth0.useDHCP = true;
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ config.services.changedetection-io.port ];
        };
      };

      environment.etc."ssl/certs/warp-net.crt".source = ../../files/warp-net-root.crt;
      security.pki.certificateFiles = [ ../../files/warp-net-root.crt ];
      system.stateVersion = "24.05";
    };
  };
}
