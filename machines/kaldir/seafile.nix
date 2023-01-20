let
  hostIP = "192.168.102.1";
  containerIP = "192.168.102.10";
  port = 80;
in
{
  containers.seafile = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;

    config = { config, pkgs, ... }: {

      services.seafile = {
        enable = true;
        adminEmail = "seafile@bonusplay.pl";
        initialAdminPassword = "T3VZ1eiUJ+ZC13VeR2FZEjY8KthmfTtD6PkVCQhNoZJqORCD";
        seafileSettings.fileserver = {
          host = "0.0.0.0";
          port = 4030;
        };
        ccnetSettings.General.SERVICE_URL = "https://s.bonusplay.pl";
        seahubExtraConf = ''
            ALLOWED_HOSTS = [ "s.bonusplay.pl" ];
        #   CSRF_COOKIE_SECURE = True;
        #   CSRF_COOKIE_SAMESITE = "Strict";
            TIME_ZONE = "Europe/Warsaw";
            SITE_TITLE = "Bonus's Seafile";
        '';
      };

      # https://github.com/NixOS/nixpkgs/pull/178873
      services.nginx = {
        enable = true;
        virtualHosts."s.bonusplay.pl" = {
          locations."/" = {
            proxyPass = "http://unix:/run/seahub/gunicorn.sock";
            recommendedProxySettings = true;
          };
        };
      };

      system.stateVersion = "22.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
      environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
    };
  };
}