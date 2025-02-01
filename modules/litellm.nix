{ lib, config, pkgs, ... }:
let
  cfg = config.custom.litellm;
  settingsFormat = pkgs.formats.yaml {};
  configFile = settingsFormat.generate "config.yml" cfg.settings;
in
{
  options.custom.litellm = {
    enable = lib.mkEnableOption "litellm";

    package = lib.mkPackageOption pkgs ["python3Packages" "litellm"] { };

    user = lib.mkOption {
      default = "litellm";
      type = lib.types.str;
      description = "User the litellm-proxy runs under.";
    };
    group = lib.mkOption {
      default = "litellm";
      type = lib.types.str;
      description = "Group the litellm-proxy runs under.";
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      type = lib.types.str;
      example = "0.0.0.0";
      description = "Host or address this litellm-proxy listens on.";
    };
    port = lib.mkOption {
      default = 4021;
      type = lib.types.port;
      example = 4021;
      description = "Port for this litellm-proxy to listen on.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File path containing environment variables for configuring the litellm-proxy service in the format of an EnvironmentFile. See {manpage}`systemd.exec(5)`.
      '';
    };

    extraArguments = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
      example = "0.0.0.0";
      description = "Host or address this litellm-proxy listens on.";
    };

    settings = lib.mkOption {
      default = {};
      type = settingsFormat.type;
      description = ''
        This will be used as .
        All settings can be viewed https://docs.litellm.ai/docs/proxy/config_settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.litellm = {
      description = "OpenAI Proxy Server (LLM Gateway) to call 100+ LLMs in a unified interface";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      restartTriggers = [ configFile ];

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/litellm \
          --host='${cfg.host}' \
          --port='${toString cfg.port}' \
          --config='${configFile}' \
          ${lib.optionalString (cfg.extraArguments != null) cfg.extraArguments}
        '';

        User = cfg.user;
        Group = cfg.user;

        EnvironmentFile = cfg.environmentFile;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        UMask = 27;
      };
    };

    users.groups.${cfg.group} = {};
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "litellm-proxy daemon user";
    };
  };
}
