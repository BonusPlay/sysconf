{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.step-ca;
  settingsFormat = (pkgs.formats.json { });
in
{
  options = {
    custom.step-ca = {
      enable = lib.mkEnableOption "the smallstep certificate authority server";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.step-ca;
        defaultText = lib.literalExpression "pkgs.step-ca";
        description = "Which step-ca package to use.";
      };
      instances = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule({ name, ...}: {
          options = {
            openFirewall = lib.mkEnableOption "opening the certificate authority server port";
            address = lib.mkOption {
              type = lib.types.str;
              example = "127.0.0.1";
              description = ''
                The address (without port) the certificate authority should listen at.
                This combined with {option}`services.step-ca.port` overrides {option}`services.step-ca.settings.address`.
              '';
            };
            port = lib.mkOption {
              type = lib.types.port;
              example = 8443;
              description = ''
                The port the certificate authority should listen on.
                This combined with {option}`services.step-ca.address` overrides {option}`services.step-ca.settings.address`.
              '';
            };
            settings = lib.mkOption {
              type = with lib.types; attrsOf anything;
              description = ''
                Settings that go into {file}`ca.json`. See
                [the step-ca manual](https://smallstep.com/docs/step-ca/configuration)
                for more information. The easiest way to
                configure this module would be to run `step ca init`
                to generate {file}`ca.json` and then import it using
                `builtins.fromJSON`.
                [This article](https://smallstep.com/docs/step-cli/basic-crypto-operations#run-an-offline-x509-certificate-authority)
                may also be useful if you want to customize certain aspects of
                certificate generation for your CA.
                You need to change the database storage path to {file}`/var/lib/step-ca/db`.

                ::: {.warning}
                The {option}`services.step-ca.settings.address` option
                will be ignored and overwritten by
                {option}`services.step-ca.address` and
                {option}`services.step-ca.port`.
                :::
              '';
            };
            intermediatePasswordFile = lib.mkOption {
              type = lib.types.pathWith {
                inStore = false;
                absolute = true;
              };
              example = "/run/keys/smallstep-password";
              description = ''
                Path to the file containing the password for the intermediate
                certificate private key.

                ::: {.warning}
                Make sure to use a quoted absolute path instead of a path literal
                to prevent it from being copied to the globally readable Nix
                store.
                :::
              '';
            };
          };
        }));
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # Generate a config file for each instance
      makeConfigFile = name: instanceCfg:
        settingsFormat.generate "ca-${name}.json" (
          instanceCfg.settings
          // {
            address = instanceCfg.address + ":" + toString instanceCfg.port;
          }
        );
      
      # Generate systemd service for each instance
      makeService = name: instanceCfg: {
        name = "step-ca-${name}";
        value = {
          wantedBy = [ "multi-user.target" ];
          restartTriggers = [ (makeConfigFile name instanceCfg) ];
          unitConfig = {
            ConditionFileNotEmpty = ""; # override upstream
          };
          serviceConfig = {
            User = "step-ca";
            Group = "step-ca";
            UMask = "0077";
            Environment = "HOME=%S/step-ca/${name}";
            WorkingDirectory = ""; # override upstream
            ReadWritePaths = ""; # override upstream

            # LocalCredential handles file permission problems arising from the use of DynamicUser.
            LoadCredential = "intermediate_password:${instanceCfg.intermediatePasswordFile}";

            ExecStart = [
              "" # override upstream
              "${cfg.package}/bin/step-ca /etc/smallstep/${name}/ca.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
            ];

            # ProtectProc = "invisible"; # not supported by upstream yet
            # ProcSubset = "pid"; # not supported by upstream yet
            # PrivateUsers = true; # doesn't work with privileged ports therefore not supported by upstream

            DynamicUser = true;
            StateDirectory = "step-ca/${name}";
          };
        };
      };

      # Collect all ports that need to be opened in the firewall
      firewallPorts = lib.flatten (
        lib.mapAttrsToList (name: instanceCfg:
          lib.optional instanceCfg.openFirewall instanceCfg.port
        ) cfg.instances
      );
    in
    {
      systemd.packages = [ cfg.package ];

      # Create configuration files for each instance
      environment.etc = lib.mapAttrs' (name: instanceCfg: {
        name = "smallstep/${name}/ca.json";
        value = {
          source = makeConfigFile name instanceCfg;
        };
      }) cfg.instances;

      # Create systemd services for each instance
      systemd.services = lib.mapAttrs' makeService cfg.instances;

      users.groups.step-ca = { };
      users.users.step-ca = {
        home = "/var/lib/step-ca";
        group = "step-ca";
        isSystemUser = true;
      };

      # Open firewall ports for instances that request it
      networking.firewall = lib.mkIf (firewallPorts != []) {
        allowedTCPPorts = firewallPorts;
      };
    }
  );
}
