{ config, ... }:
let
  name = "matrix-sliding-sync";
in
{
  age.secrets.sliding-sync = {
    file = ../../secrets/matrix/sliding-sync-environment.age;
    mode = "0400";
    owner = name;
  };

  services.${name} = {
    enable = true;
    environmentFile = config.age.secrets.sliding-sync.path;
    settings = {
      SYNCV3_SERVER = "https://matrix.bonusplay.pl";
      SYNCV3_BINDADDR = "127.0.0.1:4085";
    };
  };

  # fix no user
  systemd.services.${name}.serviceConfig = {
    User = name;
    Group = name;
  };
  users.users.${name} = {
    isSystemUser = true;
    group = name;
    home = "/var/lib/${name}";
  };
  users.groups.${name} = {};
}
