{ config, ... }:
{
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  age.secrets.p4net = {
    file = ../../secrets/artanis-p4net.age;
    mode = "0440";
    group = "systemd-network";
  };

  services.tailscale.enable = true;

  systemd.network = {
    enable = true;
    netdevs = {
      "90-p4net" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "p4net";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.p4net.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              Endpoint = "ziko.bonusplay.pl:51830";
              PublicKey = "dYowB7h2BOdVtjcLyuDmnSebKNr6DVE7lWyy+augoF0=";
              AllowedIPs = [ "198.18.0.0/16" ];
            };
          }
        ];
      };
    };
    networks = {
      "90-p4net" = {
        matchConfig.Name = "p4net";
        dns = [ "198.18.69.1" ];
        address = [ "198.18.69.201/32" ];
        domains = [ "~p4" "~18.198.in-addr.arpa" ];
        networkConfig = {
          DNSSEC = false;
        };
        routes = [
          {
            routeConfig = {
              Gateway = "198.18.69.2";
              Destination = "198.18.0.0/16";
              GatewayOnLink = true;
            };
          }
        ];
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };
}
