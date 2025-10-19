{ config, ... }:
{
  custom.beszel-hub.enable = true;

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "beszel.bonus.re";
      port = config.custom.beszel-hub.port;
    }
  ];
}
