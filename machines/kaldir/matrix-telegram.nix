{ config, ... }:
{
  age.secrets.matrixTelegramEnv = {
    file = ../../secrets/matrix-telegram-environment.age;
    mode = "0400";
    owner = "matrix-synapse";
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.age.secrets.matrixTelegramEnv.path;
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = "bonusplay.pl";
      };

      appservice = {
        address = "http://localhost:4080";
        hostname = "127.0.0.1";
        port = 4081;
        public = {
          enabled = true;
          prefix = "/telegram";
          external = "https://matrix.bonusplay.pl/telegram";
        };
      };

      bridge.permissions = {
        "@bonus:bonusplay.pl" = "admin";
      };
    };
  };
}
