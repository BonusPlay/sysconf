let
  hostPort = 4075;
  containerPort = 80;
in
{
  containers.nextcloud = {
    autoStart = true;
    forwardPorts = [{
      hostPort = port;
      containerPort = containerPort;
      protocol = "TCP";
    }];

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
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ containerPort ];
      };
    };
  };
}
