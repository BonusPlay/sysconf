{ config, pkgs, ... }:
let
  domain = "board.kncyber.pl";
in
{
  age.secrets.vikunja-tunnel = {
    file = ../../secrets/cloudflare/vikunja-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  age.secrets."vikunja-config" = {
    file = ../../secrets/vikunja-config.age;
    mode = "0440";
    group = "vikunja";
  };

  services.cloudflared.tunnels = {
    "c2794371-c63c-4b3e-9004-826ddb71fee7" = {
      credentialsFile = config.age.secrets.vikunja-tunnel.path;
      default = "http_status:404";
      ingress = {
        "${domain}" = {
          service = "http://localhost:3457";
        };
      };
    };
  };

  # Parts of this config are borrowed from:
  # https://github.com/pinpox/nixos/blob/main/modules/vikunja/default.nix

  # Vikunja doesn't allow setting openid configuration parameters (e.g.
  # openid_secret) via environment variables, so we have to treat the
  # config.yaml as a secret and can't use the nixos service

  # User and group
  users = {
    users.vikunja = {
      isSystemUser = true;
      description = "vikunja system user";
      group = "vikunja";
    };

    groups.vikunja = {
      name = "vikunja";
    };
  };

  # vikunja-api
  systemd.services.vikunja-api = {
    description = "vikunja-api";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.vikunja-api ];
    restartTriggers = [
      config.age.secrets."vikunja-config".path
    ];

    environment = {
      # General
      VIKUNJA_SERVICE_FRONTENDURL = "https://${domain}/";
      VIKUNJA_SERVICE_INTERFACE = "127.0.0.1:3456";
      VIKUNJA_SERVICE_TIMEZONE = "Europe/Warsaw";
      VIKUNJA_SERVICE_ENABLEREGISTRATION = "false";
      VIKUNJA_SERVICE_CUSTOMLOGOURL = "https://avatars.githubusercontent.com/u/79149670";
      VIKUNJA_DEFAULTSETTINGS_DISCOVERABLE_BY_NAME = "true";
      VIKUNJA_DEFAULTSETTINGS_WEEK_START = "1";
      VIKUNJA_FILES_BASEPATH = "/var/lib/vikunja/files";

      # Database
      VIKUNJA_DATABASE_DATABASE = "vikunja";
      VIKUNJA_DATABASE_HOST = "localhost";
      VIKUNJA_DATABASE_PATH = "/var/lib/vikunja/vikunja.db";
      VIKUNJA_DATABASE_TYPE = "sqlite";
      VIKUNJA_DATABASE_USER = "vikunja";

      # Mailer
      #VIKUNJA_MAILER_ENABLED = "true";
      #VIKUNJA_MAILER_HOST = "smtp.sendgrid.net";
      #VIKUNJA_MAILER_USERNAME = "apikey";
      #VIKUNJA_MAILER_FROMMAIL = "todo@0cx.de";
      #VIKUNJA_MAILER_PORT = "465";
      #VIKUNJA_MAILER_AUTHTYPE = "plain";
      #VIKUNJA_MAILER_SKIPTLSVERIFY = "false";
      #VIKUNJA_MAILER_FORCESSL = "true";

      # Monitoring Metrics
      #VIKUNJA_METRICS_ENABLED = "true";
      #VIKUNJA_METRICS_USERNAME = "prometheus";
    };

    serviceConfig = {
      Type = "simple";
      User = "vikunja";
      Group = "vikunja";
      StateDirectory = "vikunja";
      ExecStart = "${pkgs.vikunja-api}/bin/vikunja";
      Restart = "always";
      BindReadOnlyPaths = [ "${config.age.secrets.vikunja-config.path}:/etc/vikunja/config.yaml" ];
    };
  };

  # vikunja-frontend
  services.nginx = {
    enable = true;
    virtualHosts."${domain}" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 3457;
        }
      ];
      locations = {
        "/" = {
          root = "${config.services.vikunja.package-frontend}";
          tryFiles = "try_files $uri $uri/ /";
        };
        "~* ^/(api|dav|\\.well-known)/" = {
          proxyPass = "http://${config.systemd.services.vikunja-api.environment.VIKUNJA_SERVICE_INTERFACE}";
          extraConfig = ''
            client_max_body_size 20M;
          '';
        };
      };
    };
  };
}
