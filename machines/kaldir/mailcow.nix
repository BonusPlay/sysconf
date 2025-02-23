{ pkgs, ... }:
{
  systemd.services.mailcow = {
    description = "dockerized email stack";

    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      TimeoutStopSec = "15";
      WorkingDirectory = "/var/lib/mailcow";
      ExecStartPre = "${pkgs.docker-compose}/bin/docker-compose -f docker-compose.yml down";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f docker-compose.yml down";
    };
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.98.118.66" ];
      domain = "mail.warp.lan";
      port = 3010;
    }
  ];
}
