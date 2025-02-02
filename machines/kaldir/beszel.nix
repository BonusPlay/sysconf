{ config, ... }:
{
  custom.beszel-hub.enable = true;

  custom.caddy.entries = [
    {
      entrypoints = [ "100.98.118.66" ];
      domain = "beszel.warp.lan";
      port = config.custom.beszel-hub.port;
    }
  ];
}
