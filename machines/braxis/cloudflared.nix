{ config, ... }:
{
  age.secrets.tunnelPass = {
    file = ../../secrets/keycloak-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "25ffc582-8ac1-48a6-b519-093e76104d54" = {
        credentialsFile = config.age.secrets.tunnelPass.path;
        default = "http_status:404";
        ingress = {
          "keycloak.kncyber.pl" = {
            service = "http://localhost:80";
          };
        };
      };
      "3ebda45f-5c0b-4d17-a6fb-6f1d7d3f1d4c" = {
        credentialsFile = config.age.secrets.tunnelPass.path;
        default = "http_status:404";
        ingress = {
          "md.kncyber.pl" = {
            service = "http://localhost:3010";
          };
        };
      }
    };
  };
}
