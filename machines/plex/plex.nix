{ config, ... }:
let
  port = 32400;
in
{
  virtualisation.oci-containers.containers.plex = {
    image = "lscr.io/linuxserver/plex:latest";
    ports = [ "${toString port}:${toString port}" ];
    environment = {
      PUID = "1250";
      PGID = "1250";
      TZ = "Etc/UTC";
      VERSION = "docker";
    };
    environmentFiles = [
      config.age.secrets.plex-claim.path
    ];
    volumes = [
      "/var/lib/plex:/config"
      "/storage/movies:/storage/movies"
      "/storage/tvshows:/storage/tvshows"
      "/storage/music:/storage/music"
    ];
    devices = [
      "/dev/dri:/dev/dri"
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];

  age.secrets.plex-claim = {
    file = ../../secrets/plex-claim.age;
    mode = "0400";
  };
}
