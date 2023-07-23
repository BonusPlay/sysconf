{ config, lib, ... }:
{
  age.secrets.taskwarrior-key = {
    file = ../secrets/taskwarrior/bonus.age;
    mode = "0400";
    owner = "bonus";
  };

  home-manager = {
    users.bonus = {
      programs.taskwarrior = {
        enable = true;
        config = {
          taskd = {
            certificate = ../files/taskserver/bonus.cert;
            key = config.age.secrets.taskwarrior-key.path;
            # tried using relative nix-path but for some reason
            # it requires rebuilding almost every 5 minutes
            # using fullpath is easier
            ca = "/etc/nixos/files/taskserver/ca.cert";
            server = "task.bonusplay.pl:7070";
            credentials = "xakep/bonus/edfd87da-e25f-4d95-a09e-070d152c832c";
          };
          weekstart = "Monday";
          dateformat = "D/M/Y";
        };
      };
      services.taskwarrior-sync.enable = true;
    };
  };
}
