{ config, ... }:
{
  age.secrets.matrixTelegramEnv = {
    file = ../../secrets/matrix/telegram-environment.age;
    mode = "0400";
    owner = "matrix-synapse";
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.age.secrets.matrixTelegramEnv.path;
    registerToSynapse = false; # we do it manually for now
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = config.services.matrix-synapse.settings.server_name;
      };

      appservice = {
        address = "http://localhost:4081";
        hostname = "127.0.0.1";
        port = 4081;
      };

      bridge.permissions = {
        "@bonus:bonusplay.pl" = "admin";
      };
    };
  };
}
