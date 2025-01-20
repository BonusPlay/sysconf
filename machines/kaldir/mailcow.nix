{ pkgs, ... }:
{
  systemd.services.mailcow = {
    description = "dockerized email stack";
    requires = [ "podman.service" ];
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.podman ];
    serviceConfig = {
      Restart = "always";
      User = "root";
      Group = "podman";
      TimeoutStopSec = "15";
      WorkingDirectory = "/var/lib/mailcow";
      ExecStartPre = "${pkgs.podman-compose}/bin/podman-compose -f docker-compose.yml down";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose -f docker-compose.yml up";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose -f docker-compose.yml down";
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
