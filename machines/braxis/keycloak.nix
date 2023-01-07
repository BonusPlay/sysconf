{ config, ... }:
{
  age.secrets.dbPass = {
    file = ../../secrets/keycloak-pass.age;
    mode = "0440";
    group = "keycloak";
  };

  age.secrets.tunnelPass = {
    file = ../../secrets/keycloak-tunnel.age;
    mode = "0440";
    group = "keycloak";
  };

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "keycloak.kncyber.pl";
      proxy = "edge";
    };
    database.passwordFile = config.age.secrets.dbPass.path;
    initialAdminPassword = "8mJjIry1j9xNxLDT9qPbRj8taRQOzEZhRehwCVwQmHk=";
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
    };
  };
}
