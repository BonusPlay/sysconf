{ config, ... }:
let
  port = 4084;
in
{
  age.secrets.matrixSlackEnv = {
    file = ../../secrets/matrix/slack-environment.age;
    mode = "0400";
    group = "matrix-slack";
  };

  services.mautrix-slack = {
    enable = true;
    environmentFile = config.age.secrets.matrixSlackEnv.path;
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = config.services.matrix-synapse.settings.server_name;
      };

      appservice = {
        address = "http://localhost:${toString port}";
        hostname = "127.0.0.1";
        port = port;
      };

      bridge.encryption = {
        allow = true;
        default = true;
      };

      bridge.permissions = {
        "@bonus:bonusplay.pl" = "admin";
      };
    };
  };
}
