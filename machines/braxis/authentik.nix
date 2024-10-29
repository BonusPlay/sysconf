{ config, ... }:
{
  age.secrets.authentik-tunnel = {
    file = ../../secrets/cloudflare/authentik-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  age.secrets."authentik-env" = {
    file = ../../secrets/kncyber/authentik-env.age;
    mode = "0400";
    owner = "authentik";
  };

  services.cloudflared.tunnels = {
    "2674322e-9a5b-4be0-bab2-d28bca9c8615" = {
      credentialsFile = config.age.secrets.authentik-tunnel.path;
      default = "http_status:404";
      ingress = {
        "auth.kncyber.pl" = {
          service = "http://localhost:9000";
        };
        "artemis.kncyber.pl" = {
          service = "http://localhost:9000";
        };
      };
    };
  };

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
    environmentFile = config.age.secrets."authentik-env".path;
    settings = {
      #email = {
      #  host = "smtp.example.com";
      #  port = 587;
      #  username = "authentik@example.com";
      #  use_tls = true;
      #  use_ssl = false;
      #  from = "authentik@example.com";
      #};
      disable_startup_analytics = true;
    };
  };
}
