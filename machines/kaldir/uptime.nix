{ config, lib, ... }:
{
  custom.caddy.entries = [
    {
      entrypoints = [ "100.98.118.66" ];
      domain = "uptime.warp.lan";
      port = lib.strings.toInt config.services.uptime-kuma.settings.PORT;
    }
  ];

  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
    settings = {
      HOST = "0.0.0.0";
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/warp-net.crt";
    };
  };

  security.pki.certificateFiles = [ ../../files/warp-net-root.crt ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ (lib.strings.toInt config.services.uptime-kuma.settings.PORT) ];
  };
}
