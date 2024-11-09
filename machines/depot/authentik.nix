{ config, ... }:
{
  age.secrets.authentik-main = {
    file = ../../secrets/authentik/main.age;
    mode = "0400";
    owner = "authentik";
  };

  age.secrets.authentik-radius = {
    file = ../../secrets/authentik/radius.age;
    mode = "0400";
    owner = "authentik";
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.126.141.55" "127.0.0.1" ];
      domain = "auth.warp.lan";
      port = 9000;
    }
  ];

  users = {
    users.authentik = {
      isSystemUser = true;
      group = "authentik";
      home = "/var/lib/authentik";
      description = "authentik user";
    };
    groups.authentik = {};
  };

  systemd.services.authentik.serviceConfig = {
    User = "authentik";
  };
  systemd.services.authentik-migrate.serviceConfig = {
    User = "authentik";
  };
  systemd.services.authentik-worker.serviceConfig = {
    User = "authentik";
  };

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik-main.path;
    settings = {
      disable_startup_analytics = true;
    };
  };

  services.authentik-radius = {
    enable = true;
    environmentFile = config.age.secrets.authentik-radius.path;
  };
}
