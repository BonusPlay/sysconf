{ config, ... }:
{
  age.secrets.wifi = {
    file = ../../secrets/keycloak-pass.age;
    mode = "0440";
    group = "keycloak";
  };

  # load passwords
  systemd.services.wpa_supplicant.serviceConfig.EnvironmentFile = "${config.age.secrets.wifi.path}";

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "keycloak.kncyber.pl";
      proxy = "edge";
    };
    database.passwordFile = config.age.secrets.wifi.path;
    initialAdminPassword = "8mJjIry1j9xNxLDT9qPbRj8taRQOzEZhRehwCVwQmHk=";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {

    };
  };
}
