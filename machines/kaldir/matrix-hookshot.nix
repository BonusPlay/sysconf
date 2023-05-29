{ pkgs, ... }:
let
  dataDir = "/var/lib/matrix-hookshot";
  registrationFile = "${dataDir}/discord-registration.yaml";
in
{
  age.secrets.matrixHookshotRegistration = {
    file = ../../secrets/matrix-hookshot-registration.age;
    path = "/var/lib/matrix-hookshot";
    mode = "0400";
    owner = "matrix-synapse";
  };

  systemd.services.matrix-hookshot = {
    description = "A bridge between Matrix and multiple project management services, such as GitHub, GitLab and JIRA.";

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" "matrix-synapse.service" ];
    after = [ "network-online.target" "matrix-synapse.service" ];

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
      WorkingDirectory = appDir;
      StateDirectory = baseNameOf dataDir;
      UMask = "0027";
      EnvironmentFile = cfg.environmentFile;

      ExecStart = "${pkgs.matrix-hookshot}/bin/matrix-hookshot";
    };
  };
}
