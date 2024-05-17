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
      extraConfig = ''
        header +content-security-policy upgrade-insecure-requests
      '';
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

      system.stateVersion = "unstable";
      networking.extraHosts = "172.28.0.1 nextcloud.warp.lan";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };
    };
  };
}
