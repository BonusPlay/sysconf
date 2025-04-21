{ pkgs, ... }:
{
  systemd.services.web-utils = {
    description = "web-utils";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      DynamicUser = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;

      # Resource limits
      LimitNOFILE = 1024;

      # Execution
      ExecStart = "${pkgs.web-utils}/bin/web-utils";
      Restart = "on-failure";
      RestartSec = "5s";

      # Logging
      StandardOutput = "journal";
      StandardError = "journal";

      # Additional security hardening
      SystemCallFilter = [ "@system-service" "~@privileged" "@resources" ];
      SystemCallArchitectures = "native";
    };
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "tools.bonusplay.pl";
      port = 4013;
    }
  ];
}
