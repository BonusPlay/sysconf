{ config, nixpkgs-unstable, ... }:
let
  port = 4083;
in
{
  age.secrets.matrixGooglechatEnv = {
    file = ../../secrets/matrix/googlechat-environment.age;
    mode = "0400";
    owner = "matrix-synapse";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    mautrix-googlechat = nixpkgs-unstable.mautrix-googlechat;
  };

  services.mautrix-googlechat = {
    enable = true;
    environmentFile = config.age.secrets.matrixGooglechatEnv.path;
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

      bridge.permissions = {
        "@bonus:bonusplay.pl" = "admin";
      };
    };
  };
}
