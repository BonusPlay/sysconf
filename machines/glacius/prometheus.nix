{ config, ... }:
{
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
      };
      systemd = {
        enable = true;
      };
    };
  };
}
