{ config, ... }:
{
  services.mautrix-facebook = {
    enable = true;
    settings = {
      homeserver = {
        address = "http://localhost:4080";
        domain = config.services.matrix-synapse.settings.server_name;
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
