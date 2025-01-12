{ config, ... }:
let
  cconf = config.containers.archivebox;
  removeSubnet = ipWithSubnet: builtins.head (builtins.split "/" ipWithSubnet);
in
{
  #custom.caddy.entries = [
  #  {
  #    entrypoints = [ "100.84.139.31" ];
  #    domain = "watch.warp.lan";
  #    target = removeSubnet cconf.extraVeths.ve-archive.localAddress;
  #    port = cconf.config.services.archivebox.port;
  #  }
  #];

  containers.archivebox = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-mullvad";
    extraVeths.ve-archive = {
      hostAddress = "172.28.1.1/24";
      localAddress = "172.28.1.2/24";
    };

    config = { config, pkgs, lib, ... }: {
      environment.etc."ssl/certs/warp-net.crt".source = ../../files/warp-net-root.crt;
      security.pki.certificateFiles = [ ../../files/warp-net-root.crt ];

      #services.archivebox = {
      #  enable = true;
      #};

      system.stateVersion = "24.05";
      networking.firewall = {
        enable = true;
        #allowedTCPPorts = [ config.services.archivebox.port ];
      };
    };
  };
}
