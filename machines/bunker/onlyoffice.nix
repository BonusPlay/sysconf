{ config, ... }:
let
  domain = "onlyoffice.warp.lan";
in
{
  age.secrets.onlyoffice-jwt = {
    file = ../../secrets/nextcloud/onlyoffice-jwt.age;
    mode = "0444";
    owner = "root";
  };

  services.onlyoffice = {
    enable = true;
    hostname = "onlyoffice.warp.lan";
    jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;
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

  # fix FHS not accepting custom CA
  systemd.services = {
    onlyoffice-docservice.environment.NODE_EXTRA_CA_CERTS = ../../files/warp-net-root.crt;
    onlyoffice-converter.environment.NODE_EXTRA_CA_CERTS = ../../files/warp-net-root.crt;
  };
}
