{ config, ... }:
let
  jwtFilePath = "/run/adminPassFile";
  containerAddr = "172.28.0.3";
in
{
  age.secrets.onlyoffice-jwt = {
    file = ../../secrets/nextcloud/onlyoffice-jwt.age;
    mode = "0444";
    owner = "root";
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.112.114.72" "172.28.0.1" ];
      domain = "onlyoffice.warp.lan";
      target = containerAddr;
      port = 80;
      # https://github.com/ONLYOFFICE/DocumentServer/issues/2186#issuecomment-1768196783
      #extraConfig = ''
      #  header +content-security-policy upgrade-insecure-requests
      #'';
    }
  ];

  containers.onlyoffice = {
    autoStart = true;
    privateNetwork = true;
    extraVeths.ve-of = {
      hostBridge = "br-docs";
      localAddress = "${containerAddr}/24";
    };
    bindMounts.jwt = {
      hostPath = config.age.secrets.onlyoffice-jwt.path;
      mountPoint = jwtFilePath;
      isReadOnly = true;
    };

    config = { config, pkgs, lib, ... }: {
      services.onlyoffice = {
        enable = true;
        hostname = "onlyoffice.warp.lan";
        jwtSecretFile = jwtFilePath;
      };

      services.postgresql.package = pkgs.postgresql;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "corefonts"
      ];

      environment.etc."ssl/certs/warp-net.crt".source = ../../files/warp-net-root.crt;
      security.pki.certificateFiles = [ ../../files/warp-net-root.crt ];

      # fix FHS not accepting custom CA
      systemd.services = {
        onlyoffice-docservice.environment.NODE_EXTRA_CA_CERTS = ../../files/warp-net-root.crt;
        onlyoffice-converter.environment.NODE_EXTRA_CA_CERTS = ../../files/warp-net-root.crt;
      };

      services.nginx.virtualHosts.${config.services.onlyoffice.hostname}.extraConfig = lib.mkForce ''
        rewrite ^/$ /welcome/ redirect;
        rewrite ^\/OfficeWeb(\/apps\/.*)$ /${config.services.onlyoffice.package.version}/web-apps$1 redirect;
        rewrite ^(\/web-apps\/apps\/(?!api\/).*)$ /${config.services.onlyoffice.package.version}$1 redirect;

        # Ensure standard forwarded headers are set correctly
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_set_header X-Forwarded-Host $http_x_forwarded_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # required for websocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';

      system.stateVersion = "24.05";
      networking.extraHosts = "172.28.0.1 nextcloud.warp.lan";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };
    };
  };
}
