{ config, ... }:
{
  age.secrets.matrixFacebookEnv = {
    file = ../../secrets/matrix-facebook-environment.age;
    mode = "0400";
    owner = "matrix-synapse";
  };

  services.mautrix-facebook = {
    enable = true;
    environmentFile = config.age.secrets.matrixFacebookEnv.path;
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = config.services.matrix-synapse.settings.server_name;
      };

      appservice = {
        address = "http://localhost:8080";
        hostname = "127.0.0.1";
        port = 4082;
      };
    
      bridge.permissions = {
        "@bonus:bonusplay.pl" = "admin";
      };

      metrics = {
        enabled = true;
        listen_port = 9107;
      };
    };
  };
}
