{ pkgs, config, ... }:
{
  age.secrets = {
    matrixSynapseSigningKey = {
      file = ../../secrets/matrix/synapse-signing-key.age;
      path = "/var/lib/matrix-synapse/homeserver.signing.key";
      group = "matrix-synapse";
      mode = "0440";
    };
    matrixSynapseExtraConfig = {
      file = ../../secrets/matrix/synapse-extra-config.age;
      group = "matrix-synapse";
      mode = "0440";
    };
    matrixTelegramRegistration = {
      file = ../../secrets/matrix/telegram-registration.age;
      mode = "0400";
      owner = "matrix-synapse";
    };
    matrixFacebookRegistration = {
      file = ../../secrets/matrix/facebook-registration.age;
      mode = "0400";
      owner = "matrix-synapse";
    };
    #matrixHookshotRegistration = {
    #  file = ../../secrets/matrix-hookshot-registration.age;
    #  mode = "0400";
    #  owner = "matrix-synapse";
    #};
  };

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    settings = {
      server_name = "bonusplay.pl";
      public_baseurl = "https://matrix.bonusplay.pl";
      tls_private_key_path = null;
      tls_certificate_path = null;
      signing_key_path = config.age.secrets.matrixSynapseSigningKey.path;
      extraConfigFiles = config.age.secrets.matrixSynapseExtraConfig.path;
      listeners = [{
        bind_addresses = [ "127.0.0.1" ];
        port = 4080;
        resources = [{
            compress = false;
            names = [ "client" "federation" ];
        }];
        tls = false;
        type = "http";
        x_forwarded = true;
      }];
      app_service_config_files = [
        config.age.secrets.matrixTelegramRegistration.path
        config.age.secrets.matrixFacebookRegistration.path
        #config.age.secrets.matrixHookshotRegistration.path
        "/var/lib/heisenbridge/registration.yml"
      ];
    };
  };

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse WITH LOGIN";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };
}
