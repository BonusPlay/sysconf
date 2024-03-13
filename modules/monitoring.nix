{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.monitoring;
in
{
  options.custom.monitoring = {
    enable = mkEnableOption "monitoring using vector-dev";
  };

  config = mkIf cfg.enable {
    age.secrets.vector-dev = {
      file = ../secrets/vector-dev.age;
      mode = "0444";
    };

    services.vector = {
      enable = true;
      journaldAccess = true;
      settings = {
        sources = {
          metrics = {
            type = "host_metrics";
            filesystem.filesystems.includes = [ "ext*" "btrfs" ];
            #filesystem.filesystems.excludes = [ "tmpfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" "efivarfs" "pstore" "bpf" "configfs" "debugfs" "rpc_pipefs" "ramfs" "hugetlbfs" "mqueue" ];
          };
          logs = {
            type = "journald";
          };
        };

        secret.agenix = {
          type = "exec";
          command = [ "cat" config.age.secrets.vector-dev.path ];
        };

        sinks = {
          influx_metrics = {
            type = "influxdb_metrics";
            inputs = [ "metrics" ];
            bucket = "hosts";
            endpoint = "https://influx.mlwr.dev";
            org = "khala";
            token = "SECRET[agenix.influx_token]";
          };
          influx_logs = {
            type = "influxdb_logs";
            inputs = [ "logs" ];
            bucket = "hosts";
            endpoint = "https://influx.mlwr.dev";
            org = "khala";
            token = "SECRET[agenix.influx_token]";
            measurement = "vector-logs";
          };
        };
      };
    };
  };
}
