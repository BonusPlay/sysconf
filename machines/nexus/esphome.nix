{ config, ... }:
{
  custom.nginx.entries = [
    {
      entrypoints = [ "100.84.139.31" ];
      domain = "esphome.warp.lan";
      target = config.services.esphome.address;
      port = config.services.esphome.port;
    }
  ];

  services.esphome = {
    enable = true;
    usePing = true;
  };
}
