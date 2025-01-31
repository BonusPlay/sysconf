{ config, lib, ... }:
{
  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
    settings = {
      HOST = "127.0.0.1";
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/warp-net.crt";
    };
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.98.118.66" ];
      domain = "uptime.warp.lan";
      port = lib.strings.toInt config.services.uptime-kuma.settings.PORT;
    }
  ];
}
