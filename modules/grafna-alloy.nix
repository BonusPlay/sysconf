{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.grafana-alloy;
  dataDir = "/var/lib/grafna-alloy";
in {
  options = {
    services.grafana-alloy = {
      enable = mkEnableOption (lib.mdDoc "Open source OpenTelemetry Collector distribution with built-in Prometheus pipelines and support for metrics, logs, traces, and profiles");

      package = mkOption {
        default = pkgs.grafana-alloy;
        type = types.package;
        defaultText = literalExpression "pkgs.grafana-alloy";
        description = lib.mdDoc "grafana-alloy derivation to use";
      };

      configuration = mkOption {
        type = types.str;
        description = ''
          Specify the configuration for Grafana Alloy.
        '';
      };

      journaldAccess = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Should grafana-alloy user be added to systemd-journal group
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Specify a list of additional command line flags,
          which get escaped and are then passed to Grafana Alloy.
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc ''
          Environment file used by grafna-alloy service.
          Can be used for storing the secrets without making them available in the Nix store.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.grafana-alloy = {
      description = "OpenTelemetry Collector distribution with programmable pipelines";

      wantedBy = [ "multi-user.target" ];
      stopIfChanged = false;

      serviceConfig = {
        Restart = "on-failure";

        ExecStart = "${cfg.package}/bin/alloy run --disable-reporting --storage.path=${dataDir} ${escapeShellArgs cfg.extraFlags} ${pkgs.writeText "grafana-alloy.config" cfg.configuration}";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        PrivateMounts = true;
        CacheDirectory = "grafana-alloy";

        WorkingDirectory = dataDir;
        ReadWritePaths = dataDir;
        StateDirectory = baseNameOf dataDir;

        User = "grafana-alloy";
        Group = "grafana-alloy";

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;

        ProtectKernelModules = true;
        SystemCallArchitectures = "native";
        ProtectKernelLogs = true;
        ProtectClock = true;

        LockPersonality = true;
        ProtectHostname = true;
        RestrictRealtime = true;
        MemoryDenyWriteExecute = true;
        PrivateUsers = true;

        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        SupplementaryGroups = lib.optional (cfg.journaldAccess) "systemd-journal";
      };
    };

    users.groups.grafana-alloy = {};
    users.users.grafana-alloy = {
      description = "Grafana Alloy service user";
      isSystemUser = true;
      group = "grafana-alloy";
    };
  };
}
