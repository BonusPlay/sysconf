{ config, pkgs, ... }:
let
  port = 4082;
in
{
  age.secrets.matrixMetaEnv = {
    file = ../../secrets/matrix/meta-environment.age;
    mode = "0400";
    owner = "mautrix-meta";
  };

  services.mautrix-meta = {
    enable = true;
    package = pkgs.callPackage ../../pkgs/mautrix-meta.nix {};
    environmentFile = config.age.secrets.matrixMetaEnv.path;
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = config.services.matrix-synapse.settings.server_name;
      };

      appservice = {
        address = "http://localhost:${toString port}";
        hostname = "127.0.0.1";
        port = port;
        database = {
          type = "sqlite3-fk-wal";
          uri = "file:${config.services.mautrix-meta.dataDir}/mautrix-meta.db?_txlock=immediate";
        };
        id = "facebook";
        bot = {
          username = "facebookbot";
          displayname = "Facebook bridge bot";
          avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
        };
      };

      meta.mode = "facebook";
    
      bridge = {
        username_template = "facebook_{{.}}";
        displayname_template = "{{or .DisplayName .Username}} (FB)";

        encryption = {
          allow = true;
          default = true;
        };

        permissions = {
          "@bonus:bonusplay.pl" = "admin";
        };
      };

      #metrics = {
      #  enabled = true;
      #  listen_port = 9107;
      #};
    };
  };
}
