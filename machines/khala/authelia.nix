{ config, lib, ... }:
{
  services.authelia.instances.main = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
    secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      log.level = "debug";
      server.disable_healthcheck = true;
      secrets = {
        jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-issuer-private-key.path;
        oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac-secret.path;
        sessionSecretFile = config.age.secrets.authelia-session-secret.path;
        storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
      };
      session.cookies = [
        {
          domain = "bonus.re";
          authelia_url = "https://auth.bonus.re";
          # The period of time the user can be inactive for before the session is destroyed
          inactivity = "1M";
          # The period of time before the cookie expires and the session is destroyed
          expiration = "7d";
          # The period of time before the cookie expires and the session is destroyed
          # when the remember me box is checked
          remember_me = "30d";
        }
      ];
      storage.postgres = {
        address = "unix:///run/postgresql";
        database = "authelia";
        username = "authelia";
      };
      authentication_backend = {
        file.path = config.age.secrets.authelia-users.path;
      };
      settingsFiles = [
        config.age.secrets.authelia-acls.path
      ];
    };
  };

  services.postgresql = {
    enable = true;
  };

  age.secrets = let
    mkSecret = name: {
      name = "authelia-${name}";
      value = {
        file = ../../secrets/authelia + "/${name}.age";
        mode = "0400";
        owner = config.services.authelia.instances.main.user;
      };
    };

    vars = [
      "jwt-secret"
      "oidc-issuer-private-key"
      "oidc-hmac-secret"
      "session-secret"
      "storage-encryption-key"
      "users"
      "acls"
    ];
  in
    lib.listToAttrs (map mkSecret vars);
}
