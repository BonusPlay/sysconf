{ config, ... }:
{
  custom.beszel-hub.enable = true;

  custom.caddy.entries = [
    {
      domain = "beszel.bonus.re";
      port = config.custom.beszel-hub.port;
    }
  ];
}
