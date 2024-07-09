{ config, ... }:
let
  adminPassFile = "/run/adminPassFile";
  s3secretFile = "/run/s3secret";
  containerAddr = "172.28.0.2";
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

  custom.caddy.entries = [
    {
      entrypoints = [ "100.112.114.72" "172.28.0.1" ];
      domain = "nextcloud.warp.lan";
      #target = config.containers.nextcloud.localAddress;
      target = containerAddr;
      port = 80;
    }
  ];

  # for some unknown to me reason, nextcloud attempts to connect to onlyoffice to port :80 no matter what
  # this is a workaround for that
  networking.firewall.interfaces.br-docs.allowedTCPPorts = [ 80 443 ];

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    extraVeths.ve-nc = {
      hostBridge = "br-docs";
      localAddress = "${containerAddr}/24";
    };
    bindMounts.adminpassFile = {
      hostPath = config.age.secrets.nextcloud-admin-pass.path;
      mountPoint = adminPassFile;
      isReadOnly = true;
    };
    bindMounts.s3secretFile = {
      hostPath = config.age.secrets.nextcloud-s3-secret.path;
      mountPoint = s3secretFile;
      isReadOnly = true;
    };
    bindMounts.warpCaCert = {
      #hostPath = toString ../../files/warp-net-root.crt; WHY THE FUCK DOES THIS NOT WORK
      hostPath = "/etc/ssl/certs/warp-net.crt";
      mountPoint = "${config.containers.nextcloud.config.services.nextcloud.datadir}/data/files_external/warp.crt";
      isReadOnly = true;
    };

    config = { config, pkgs, ... }: {
      services.nextcloud = {
        enable = true;
	package = pkgs.nextcloud29;
        hostName = "nextcloud.warp.lan";
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
        config = {
	  adminpassFile = adminPassFile;
	  #objectstore.s3 = {
	  #  enable = true;
	  #  hostname = "s3.warp.lan";
	  #  key = "iKqEzDBpQowqM7TuWdDC"; # access-key
	  #  region = "eu-warp-1";
	  #  bucket = "nextcloud";
	  #  secretFile = s3secretFile;
	  #  usePathStyle = true;
	  #  autocreate = false;
	  #};
	};
      };

      environment.etc."ssl/certs/warp-net.crt".source = ../../files/warp-net-root.crt;
      security.pki.certificateFiles = [ ../../files/warp-net-root.crt ];

      system.stateVersion = "unstable";
      networking.extraHosts = "172.28.0.1 onlyoffice.warp.lan";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };
    };
  };
}
