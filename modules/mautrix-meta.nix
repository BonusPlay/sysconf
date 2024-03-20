{ config, pkgs, lib, ... }:

with lib;

let
  registrationFile = "${dataDir}/meta-registration.yaml";
  cfg = config.services.mautrix-meta;
  dataDir = cfg.dataDir;
  pkg = cfg.package;
  settingsFormat = pkgs.formats.yaml {};
  settingsFile = "${dataDir}/config.yaml";
  settingsFileUnsubstituted =
    settingsFormat.generate "mautrix-meta-config.yaml" cfg.settings;
in {
  options = {
    services.mautrix-meta = {
      enable = mkEnableOption (mdDoc "Mautrix-Meta, a Matrix <-> Facebook and Matrix <-> Instagram hybrid puppeting/relaybot bridge");

      package = mkPackageOption pkgs "mautrix-meta" { };

      dataDir = mkOption {
        type = types.path;
        default =  "/var/lib/mautrix-meta";
        description = mdDoc ''
          Path to the directory with database, registration, and other data for the bridge service.
        '';
      };

      settings = mkOption rec {
        apply = recursiveUpdate default;
        inherit (settingsFormat) type;
        default = {
          homeserver = {
            software = "standard";
          };

          appservice = rec {
            database = {
              type = "sqlite3-fk-wal";
              uri = "file:${dataDir}/mautrix-meta.db?_txlock=immediate";
            };

            hostname = "0.0.0.0";
            port = 29319;
            address = "http://localhost:${toString cfg.settings.appservice.port}";
          };

          meta = {
            mode = "instagram";
          };

          logging = {
            min_level = "info";
            writers = singleton {
              type = "stdout";
              format = "pretty-colored";
              time_format = " ";
            };
          };
        };
        defaultText = ''
        {
          homeserver = {
            software = "standard";
          };
          appservice = rec {
            database = {
              type = "sqlite3-fk-wal";
              uri = "''${config.services.mautrix-meta.dataDir}/mautrix-meta.db?_txlock=immediate";
            };
            hostname = "0.0.0.0";
            port = 29319;
            address = "http://localhost:''${toString config.services.mautrix-mega.appservice.port}";
          };
          meta = {
            mode = "instagram";
          };
          logging = {
            min_level = "info";
            writers = singleton {
              type = "stdout";
              format = "pretty-colored";
              time_format = " ";
            };
          };
        };
        '';
        description = lib.mdDoc ''
          {file}`config.yaml` configuration as a Nix attribute set.
          Configuration options should match those described in
          [example-config.yaml](https://github.com/mautrix/meta/blob/main/example-config.yaml).
          Secret tokens should be specified using {option}`environmentFile`
          instead
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc ''
          File containing environment variables to substitute when copying the configuration
          out of Nix store to the `services.mautrix-meta.dataDir`.
          Can be used for storing the secrets without making them available in the Nix store.
          For example, you can set `services.mautrix-meta.settings.appservice.as_token = "$MAUTRIX_META_APPSERVICE_AS_TOKEN"`
          and then specify `MAUTRIX_META_APPSERVICE_AS_TOKEN="{token}"` in the environment file.
          This value will get substituted into the configuration file as as token.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit;
        defaultText = literalExpression ''
          optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit
        '';
        description = lib.mdDoc ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    users = {
      users.mautrix-meta = {
        isSystemUser = true;
        group = "mautrix-meta";
        home = dataDir;
        description = "Mautrix-Meta bridge user";
      };
      groups.mautrix-meta = {};
    };

    systemd.services.mautrix-meta = {
      description = "Mautrix-Meta, a Matrix <-> Facebook or Matrix <-> Instagram hybrid puppeting/relaybot bridge";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      environment.HOME = dataDir;

      preStart = ''
        # substitute the settings file by environment variables
        # in this case read from EnvironmentFile
        test -f '${settingsFile}' && rm -f '${settingsFile}'
        old_umask=$(umask)
        umask 0177
        ${pkgs.envsubst}/bin/envsubst \
          -o '${settingsFile}' \
          -i '${settingsFileUnsubstituted}'
        umask $old_umask
        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${pkg}/bin/mautrix-meta \
            --generate-registration \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
        umask 0177
        ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
          | .[0].appservice.hs_token = .[1].hs_token
          | .[0]' '${settingsFile}' '${registrationFile}' \
          > '${settingsFile}.tmp'
        mv '${settingsFile}.tmp' '${settingsFile}'
        umask $old_umask
      '';

      serviceConfig = {
        Type = "simple";
        User = "mautrix-meta";
        Group = "mautrix-meta";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        SystemCallFilter = ["@system-service"];
        UMask = 0027;

        DynamicUser = true;
        WorkingDirectory = dataDir;
        ReadWritePaths = dataDir;
        StateDirectory = baseNameOf dataDir;
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${pkg}/bin/mautrix-meta \
            --config='${settingsFile}'
        '';
      };
      restartTriggers = [settingsFileUnsubstituted];
    };
  };

  meta.maintainers = with maintainers; [ rutherther ];
}
