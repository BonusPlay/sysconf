{ config, pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.bonus.re";
    https = true;
    configureRedis = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts calendar maps richdocuments tasks;
    };
    settings.trusted_proxies = [ "192.168.116.29" ];
    extraAppsEnable = true;
    phpOptions = {
      upload_max_filesize = "512M";
      post_max_size = "512M";
    };
    config = {
      adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
      objectstore.s3 = {
        enable = true;
        hostname = "s3.warp.lan";
        key = "GKb9a92eff75e0da3789d057ca"; # access-key
        region = "garage";
        bucket = "nextcloud";
        secretFile = config.age.secrets.nextcloud-s3-secret.path;
        usePathStyle = true;
        autocreate = false;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  age.secrets = {
    nextcloud-admin-pass = {
      file = ../../secrets/nextcloud/admin-pass.age;
      mode = "0400";
      owner = "nextcloud";
    };
    nextcloud-s3-secret = {
      file = ../../secrets/nextcloud/s3-secret.age;
      mode = "0400";
      owner = "nextcloud";
    };
  };
}
