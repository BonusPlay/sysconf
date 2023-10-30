let
  hostPort = 4075;
  containerPort = 80;
  adminPassFile = "/run/adminPassFile";
in
{
  age.secrets.nextcloud-admin-pass = {
    file = ../secrets/nextcloud/admin-pass.age;
    mode = "0444";
    owner = "root";
  };

  containers.nextcloud = {
    autoStart = true;
    forwardPorts = [{
      hostPort = hostPort;
      containerPort = containerPort;
      protocol = "TCP";
    }];
    bindMounts.adminpassFile = {
      hostPath = config.age.secrets.nextcloud-admin-pass.path;
      mountPoint = adminPassFile;
      isReadOnly = true;
    };

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
