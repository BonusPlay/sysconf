{ config, ... }:
let
  containerPort = 80;
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

  custom.traefik.entries = [
    {
      name = "nextcloud-pub";
      domain = "nextcloud.bonusplay.pl";
      target = config.containers.nextcloud.localAddress;
      port = 80;
      middlewares = [
        {
          nextcloudAuth.basicAuth = {
            usersFile = config.age.secrets.nextcloudUsersFile.path;
            removeHeader = true;
          };
        }
        nextcloudMiddleware
      ];
      entrypoints = [ "webs" ];
    }
    {
      name = "nextcloud-int";
      domain = "nextcloud-int.bonusplay.pl";
      target = config.containers.nextcloud.localAddress;
      port = 80;
      middlewares = [
        nextcloudMiddleware
      ];
      entrypoints = [ "warps" ];
    }
  ];

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
        hostName = "nextcloud.bonusplay.pl";
        https = true;
        configureRedis = true;
        #extraApps = with config.services.nextcloud.package.packages.apps; {
        #  inherit news contacts calendar tasks;
        #};
        #extraAppsEnable = true;
        phpOptions = {
          upload_max_filesize = "1G";
          post_max_size = "1G";
        };
        config = {
          adminpassFile = adminPassFile;
          extraTrustedDomains = [ "nextcloud-int.bonusplay.pl" ];
        };
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ containerPort ];
      };
    };
  };
}
