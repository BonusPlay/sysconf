{ config, ... }:
{
  age.secrets.keycloakPass = {
    file = ../../secrets/cloudflare/keycloak-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  age.secrets.hedgedocPass = {
    file = ../../secrets/cloudflare/hedgedoc-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  age.secrets.taigaPass = {
    file = ../../secrets/cloudflare/taiga-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "25ffc582-8ac1-48a6-b519-093e76104d54" = {
        credentialsFile = config.age.secrets.keycloakPass.path;
        default = "http_status:404";
        ingress = {
          "keycloak.kncyber.pl" = {
            service = "http://localhost:80";
          };
        };
      };
      "3ebda45f-5c0b-4d17-a6fb-6f1d7d3f1d4c" = {
        credentialsFile = config.age.secrets.hedgedocPass.path;
        default = "http_status:404";
        ingress = {
          "md.kncyber.pl" = {
            service = "http://localhost:3010";
          };
        };
      };
      "c37a8bd7-f81c-49a6-a290-b08dcaa1e0c5" = {
        credentialsFile = config.age.secrets.taigaPass.path;
        default = "http_status:404";
        ingress = {
          "taiga.kncyber.pl" = {
            service = "http://localhost:9000";
          };
        };
      };
    };
  };
}
