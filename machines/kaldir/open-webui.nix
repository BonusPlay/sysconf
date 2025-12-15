{ config, ... }:
{
  services.open-webui = {
    enable = true;
    port = 4020;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "ai.bonus.re";
      port = config.services.open-webui.port;
    }
  ];
}
