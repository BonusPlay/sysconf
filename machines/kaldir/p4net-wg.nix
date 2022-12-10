{ config, lib, ... }:
let
  p4netConfig = (import ./p4net-config.nix);
in with p4netConfig;
{
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  age.secrets.p4netExternal = {
    file = ../../secrets/kaldir-p4net-ext.age;
    mode = "0440";
    group = "systemd-network";
  };

  # TODO: create this from peers above
  services.p4net = {
    enable = true;
    privateKeyFile = config.age.secrets.p4netExternal.path;
    instances = {
      "p4net-chv" = {
        listenPort = 51820;
        ips = [ "198.18.69.1" ];
        allowedIPsAsRoutes = false;
        peers = [{
          route = "198.18.1.1";
          publicKey = "n95378M/NgKYPLl2vpxYA32tLt8JJ3u3BsNP0ykSiS8=";
          allowedIPs = [ "${p4subnet}" ];
          endpoint = "130.61.129.131:51820";
        }];
      };
      "p4net-dms" = {
        listenPort = 51821;
        ips = [ "198.18.69.1" ];
        allowedIPsAsRoutes = false;
        peers = [{
          route = "198.18.57.1";
          publicKey = "O9E4d7jJaguaZLgosbPhpWUKA8EYX2doMTsJeMiC3W8=";
          allowedIPs = [ "${p4subnet}" ];
          endpoint = "duck.dominikoso.me:51821";
        }];
      };
      "p4net-msm" = {
        listenPort = 51822;
        ips = [ "198.18.69.1" ];
        allowedIPsAsRoutes = false;
        peers = [{
          route = "198.18.70.1";
          publicKey = "3hnEZtMv/k9PnoSAbEMrccG6bA3Paq1vwOafppGJlRc=";
          allowedIPs = [ "${p4subnet}" ];
          endpoint = "145.239.81.240:51820";
        }];
      };
    };
  };

  networking.firewall = {
    # wireguard
    allowedUDPPorts = lib.mapAttrsToList (_: peer: peer.listenPort) p4netConfig.peers;
  };
}
