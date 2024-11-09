{ config, pkgs, ... }:
let
  domain = "nextcloud.warp.lan";
in
{
  age.secrets = {
    nextcloud-admin-pass = {
      file = ../../secrets/nextcloud/admin-pass.age;
      mode = "0444";
      owner = "root";
    };
    nextcloud-s3-secret = {
      file = ../../secrets/nextcloud/s3-secret.age;
      mode = "0444";
      owner = "root";
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = domain;
    https = true;
    configureRedis = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts calendar maps onlyoffice tasks;
    };
    extraAppsEnable = true;
    phpOptions = {
      upload_max_filesize = "512M";
      post_max_size = "512M";
    };
    config = {
      adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
      #objectstore.s3 = {
      #  enable = true;
      #  hostname = "s3.warp.lan";
      #  key = "GKb9a92eff75e0da3789d057ca"; # access-key
      #  region = "garage";
      #  bucket = "nextcloud";
      #  secretFile = config.age.secrets.nextcloud-s3-secret.path;
      #  usePathStyle = true;
      #  autocreate = false;
      #};
    };
  };

  # https
  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    listenAddresses = [ "100.112.114.72" "127.0.0.1" ];
  };
  security.acme = {
    acceptTerms = true;
    certs.${domain} = {
      server = "https://pki.warp.lan/acme/warp/directory";
      email = "acme@${domain}";
      reloadServices = [ "nginx" ];
      group = "nginx";
    };
  };

  # fix for tailscale blocking localhost
  networking.hosts."127.0.0.1" = [ domain ];
}
