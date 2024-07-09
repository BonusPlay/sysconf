{ pkgs, ... }:
let
  dataDir = "/var/lib/chibi";
  acmeDir = "/var/lib/acme/bonusplay.pl";
in
{
  virtualisation.oci-containers.containers = {
    chibisafe = {
      image = "chibisafe/chibisafe:latest";
      ports = [ "4061:8001" ];
      environment.BASE_API_URL="https://upload.bonusplay.pl";
    };
    chibisafe_server = {
      image = "chibisafe/chibisafe-server:latest";
      ports = [ "4060:8000" ];
      volumes = [
        "${dataDir}/database:/app/database:rw"
        "${dataDir}/logs:/app/logs:rw"
      ];
    };
  };

  services.caddy.virtualHosts."upload.bonusplay.pl" = {
    listenAddresses = [ "10.0.0.131" ];
    extraConfig = ''
      tls ${acmeDir}/fullchain.pem ${acmeDir}/key.pem
      header -Server
      route {
        file_server * {
          root /app/uploads
          pass_thru
        }

        @api path /api/*
        reverse_proxy @api http://127.0.0.1:4060 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        @docs path /docs*
        reverse_proxy @docs http://127.0.0.1:4060 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
        }

        reverse_proxy http://127.0.0.1:4061 {
          header_up Host {http.reverse_proxy.upstream.hostport}
          header_up X-Real-IP {http.request.header.X-Real-IP}
        }
      }
    '';
  };
}
