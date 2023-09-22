{ config, pkgs, lib, ... }:
with lib;
let
  dataDir = "/var/lib/mautrix-slack";
  registrationFile = "${dataDir}/slack-registration.yaml";
  cfg = config.services.mautrix-slack;
  settingsFormat = pkgs.formats.json {};
  settingsFile = settingsFormat.generate "mautrix-slack-config.json" cfg.settings;
  mautrix-slack = pkgs.callPackage ../pkgs/mautrix-slack.nix {};
in
{
  options = {
    services.mautrix-slack = {
      enable = mkEnableOption (lib.mdDoc "A Matrix-Slack puppeting bridge");

      settings = mkOption rec {
        apply = recursiveUpdate default;
        inherit (settingsFormat) type;
        default = {
          homeserver = {
            software = "standard";
          };

          appservice = rec {
            database = "sqlite:///${dataDir}/mautrix-slack.db";
            database_opts = {};
            hostname = "0.0.0.0";
            port = 8080;
            address = "http://localhost:${toString port}";
          };

          bridge = {
            permissions."*" = "relay";
            double_puppet_server_map = {};
            login_shared_secret_map = {};
          };

          logging = {
            min_level = "info";
            writers = [
              {
                type = "stdout";
                format = "pretty-colored";
              }
            ];
          };
        };
        example = literalExpression ''
          {
            homeserver = {
              address = "http://localhost:8008";
              domain = "public-domain.tld";
            };

            appservice.public = {
              prefix = "/public";
              external = "https://public-appservice-address/public";
            };

            bridge.permissions = {
              "example.com" = "full";
              "@admin:example.com" = "admin";
            };
          }
        '';
        description = lib.mdDoc ''
          {file}`config.yaml` configuration as a Nix attribute set.
          Configuration options should match those described in
          [example-config.yaml](https://github.com/mautrix/slack/blob/main/example-config.yaml).

          Secret tokens should be specified using {option}`environmentFile`
          instead of this world-readable attribute set.
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          File containing environment variables to be passed to the mautrix-slack service,
          in which secret tokens can be specified securely by defining values for e.g.
          `MAUTRIX_SLACK_APPSERVICE_AS_TOKEN`,
          `MAUTRIX_SLACK_APPSERVICE_HS_TOKEN`.

          These environment variables can also be used to set other options by
          replacing hierarchy levels by `.`, converting the name to uppercase
          and prepending `MAUTRIX_SLACK_`.
          For example, the first value above maps to
          {option}`settings.appservice.as_token`.

          The environment variable values can be prefixed with `json::` to have
          them be parsed as JSON. For example, `login_shared_secret_map` can be
          set as follows:
          `MAUTRIX_SLACK_BRIDGE_LOGIN_SHARED_SECRET_MAP=json::{"example.com":"secret"}`.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
        defaultText = literalExpression ''
          optional config.services.matrix-synapse.enable "matrix-synapse.service"
        '';
        description = lib.mdDoc ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mautrix-slack = {
      description = "A Matrix-Slack puppeting bridge";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${mautrix-slack}/bin/mautrix-slack \
            --generate-registration \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        DynamicUser = true;
        PrivateTmp = true;
        StateDirectory = baseNameOf dataDir;
        UMask = "0027";
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${mautrix-slack}/bin/mautrix-slack \
            --config='${settingsFile}'
        '';
      };
    };
  };

  #meta.maintainers = with maintainers; [ pacien vskilet ];
}
