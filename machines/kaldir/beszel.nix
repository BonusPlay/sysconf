{ config, ... }:
{
  custom.beszel-hub = {
    enable = true;
    environment.BESZEL_HUB_AUTO_LOGIN = "admin@bonus.re";
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "beszel.bonus.re";
      port = config.custom.beszel-hub.port;
    }
  ];
}
