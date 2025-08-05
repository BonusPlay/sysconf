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
    #matrixMetaRegistration = {
    #  file = ../../secrets/matrix/meta-registration.age;
    #  mode = "0400";
    #  owner = "matrix-synapse";
    #};
    matrixSlackRegistration = {
      file = ../../secrets/matrix/slack-registration.age;
      mode = "0400";
      owner = "matrix-synapse";
    };
    #matrixHookshotRegistration = {
    #  file = ../../secrets/matrix-hookshot-registration.age;
    #  mode = "0400";
    #  owner = "matrix-synapse";
    #};
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "matrix.bonusplay.pl";
      target = null;
      port = null;
      isPublic = true;
      extraConfig = ''
        @client path_regexp client ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)
        reverse_proxy @client http://localhost:4085 {
            header_up Host {host}
        }
        # Proxy for _matrix and _synapse endpoints
        @matrix path_regexp matrix ^(/_matrix|/_synapse/client)
        reverse_proxy @matrix http://localhost:4080 {
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
            header_up Host {host}
        }
      '';
    }
  ];

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    plugins = [ config.services.matrix-synapse.package.plugins.matrix-synapse-s3-storage-provider ];
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
      database.name = "psycopg2";
      app_service_config_files = [
        config.age.secrets.matrixTelegramRegistration.path
        #config.age.secrets.matrixMetaRegistration.path
        config.age.secrets.matrixSlackRegistration.path
        #config.age.secrets.matrixHookshotRegistration.path
        "/var/lib/heisenbridge/registration.yml"
      ];
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse WITH LOGIN";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };
}
