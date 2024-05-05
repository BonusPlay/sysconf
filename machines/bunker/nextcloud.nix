{ config, ... }:
let
  adminPassFile = "/run/adminPassFile";
  nextcloudMiddleware = {
    nextcloudHeaders.headers = {
      hostsProxyHeaders = [
        "X-Forwarded-Host"
      ];
      referrerPolicy = "same-origin";
    };
  };
in
{
  age.secrets.nextcloud-admin-pass = {
    file = ../../secrets/nextcloud/admin-pass.age;
    mode = "0444";
    owner = "root";
  };

  age.secrets.nextcloudUsersFile = {
    file = ../../secrets/nextcloud/basic-auth.age;
    mode = "0400";
    owner = "traefik";
  };

  # TODO: cloudflare doesn't have SSL cert for this domain

  #age.secrets.nextcloud-tunnel = {
  #  file = ../../secrets/cloudflare/nextcloud-tunnel.age;
  #  mode = "0400";
  #  owner = "cloudflared";
  #};

  #services.cloudflared = {
  #  enable = true;
  #  tunnels = {
  #    "a246de8c-52fb-4958-8bae-ef0e9b6e663f" = {
  #      credentialsFile = config.age.secrets.nextcloud-tunnel.path;
  #      default = "http_status:404";
  #      ingress = {
  #        "nextcloud.bonusplay.pl" = {
  #          service = "https://localhost:443";
  #        };
  #      };
  #    };
  #  };
  #};

  custom.traefik = {
    entries = [
      #{
      #  name = "nextcloud-pub";
      #  domain = "nextcloud.bonusplay.pl";
      #  target = config.containers.nextcloud.localAddress;
      #  port = 80;
      #  middlewares = [
      #    {
      #      nextcloudAuth.basicAuth = {
      #        usersFile = config.age.secrets.nextcloudUsersFile.path;
      #        removeHeader = true;
      #      };
      #    }
      #    nextcloudMiddleware
      #  ];
      #  entrypoints = [ "webs" ];
      #}
      {
        name = "nextcloud-int";
        domain = "nextcloud.mlwr.dev";
        target = config.containers.nextcloud.localAddress;
        port = 80;
        middlewares = [
          nextcloudMiddleware
        ];
        entrypoints = [ "warps" ];
      }
    ];
  };

  containers.nextcloud = {
    autoStart = true;
    bindMounts.adminpassFile = {
      hostPath = config.age.secrets.nextcloud-admin-pass.path;
      mountPoint = adminPassFile;
      isReadOnly = true;
    };
    privateNetwork = true;
    hostAddress = "172.28.3.1";
    localAddress = "172.28.3.2";

    config = { config, pkgs, ... }: {
      services.nextcloud = {
        enable = true;
	package = pkgs.nextcloud29;
        hostName = "nextcloud.bonusplay.pl";
        https = true;
        configureRedis = true;
        extraApps = with config.services.nextcloud.package.packages.apps; {
	  # 05-05-2024 tasks is broken
          inherit contacts calendar forms maps onlyoffice polls;
        };
        extraAppsEnable = true;
        phpOptions = {
          upload_max_filesize = "512M";
          post_max_size = "512M";
        };
        settings = {
          trusted_domains = [ "nextcloud.bonusplay.pl" "nextcloud.mlwr.dev" ];
        };
        config.adminpassFile = adminPassFile;
      };

      system.stateVersion = "unstable";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };
    };
  };
}
