{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.monitoring;
in
{
  options.custom.monitoring = {
    enable = mkEnableOption "monitoring using telegraf";
  };

  config = mkIf cfg.enable {
    age.secrets.telegraf = {
      file = ../secrets/telegraf-env.age;
      mode = "0400";
      owner = "telegraf";
    };

    services.telegraf = {
      enable = true;
      environmentFiles = [ config.age.secrets.telegraf.path ];
      extraConfig = {
        inputs = {
          cpu = {
            ## Whether to report per-cpu stats or not
            percpu = true;
            ## Whether to report total system cpu stats or not
            totalcpu = true;
            ## If true, collect raw CPU time metrics
            collect_cpu_time = false;
            ## If true, compute and report the sum of all non-idle CPU states
            report_active = false;
          };
          disk = {
            ignore_fs = [ "tmpfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
          };
          diskio = {};
          mem = {};
          nstat = {};
          processes = {};
          swap = {};
          system = {};
        };
        outputs = {
          influxdb_v2 = {
            urls = [ "https://influx.mlwr.dev" ];
            token = "$INFLUX_TOKEN";
            organization = "khala";
            bucket = "hosts";
            content_encoding = "gzip";
          };
        };
      };
    };
  };
}
