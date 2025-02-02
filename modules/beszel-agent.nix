{ lib, config, pkgs, ... }:
let
  cfg = config.custom.beszel-agent;
in
{
  options.custom.beszel-agent = {
    enable = lib.mkEnableOption "beszel-agent";

    package = lib.mkPackageOption pkgs "beszel" { };

    user = lib.mkOption {
      default = "beszel-agent";
      type = lib.types.str;
      description = "User the beszel-agent runs under.";
    };
    group = lib.mkOption {
      default = "beszel-agent";
      type = lib.types.str;
      description = "Group the beszel-agent runs under.";
    };

    environment = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Environment variables for configuring the beszel-agent service.
        This field will end up public in /nix/store, for secret values use `environmentFile`.
      '';
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File path containing environment variables for configuring the beszel-agent service in the format of an EnvironmentFile. See {manpage}`systemd.exec(5)`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.beszel-agent = {
      description = "Beszel Agent";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = cfg.environment;

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/beszel-agent
        '';

        User = cfg.user;
        Group = cfg.user;

        EnvironmentFile = cfg.environmentFile;

        DynamicUser = true;
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
      description = "beszel agent daemon user";
    };
  };
}
