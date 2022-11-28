{ config, ... }:
{
  age.secrets.p4netInternal = {
    file = ../../secrets/kaldir-p4net-int.age;
    mode = "0440";
    group = "systemd-network";
  };

  services.p4net = {
    enable = true;
    privateKeyFile = config.age.secrets.p4netInternal.path;
    ips = [ "198.18.66.1/24" "198.18.67.1/24" "198.18.68.1/24" "198.18.69.1/24" ];
    instances = {
      empire = {
        peers = [
          { # shakuras
            route = "198.18.69.2";
            publicKey = "dYowB7h2BOdVtjcLyuDmnSebKNr6DVE7lWyy+augoF0=";
            allowedIPs = [ "198.18.66.2" "198.18.67.0/24" "198.18.68.0/24" "198.18.69.0/24" ];
            endpoint = "shakuras.bonusplay.pl:51830";
          }
          { # artanis
            publicKey = "Cx9jMlATpGfYI5Z+9y/4vTPcYbr5xdtPtnbSJ4EekwY=";
            allowedIPs = [ "198.18.66.201" ];
          }
        ];
      };
    };
  };

  # TODO: gsocket
}
