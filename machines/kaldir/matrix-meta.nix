{ config, pkgs, ... }:
let
  port = 4082;
in
{
  age.secrets.matrixMetaEnv = {
    file = ../../secrets/matrix/meta-environment.age;
    mode = "0440";
    group = "mautrix-meta";
  };

  services.mautrix-meta.package = pkgs.callPackage ../../pkgs/mautrix-meta.nix {};
  services.mautrix-meta.instances.facebook = {
    enable = true;
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
        #database = {
        #  type = "sqlite3-fk-wal";
        #  uri = "file:${config.services.mautrix-meta.instances.facebook.dataDir}/mautrix-meta.db?_txlock=immediate";
        #};
        id = "facebook";
        bot = {
          username = "facebookbot";
          displayname = "Facebook bridge bot";
          avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
        };
      };

      network = {
        displayname_template = "{{or .DisplayName .Username}} (FB)";
        mode = "facebook";
      };

      bridge = {
        username_template = "facebook_{{.}}";

        encryption = {
          allow = true;
          default = true;
        };

        permissions = {
          "@bonus:bonusplay.pl" = "admin";
        };
      };
    };
  };
}
