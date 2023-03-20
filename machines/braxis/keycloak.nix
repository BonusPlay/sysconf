{ config, ... }:
{
  age.secrets.dbPass = {
    file = ../../secrets/keycloak-pass.age;
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
}
