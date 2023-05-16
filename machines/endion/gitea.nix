{
  containers.gitea = {
    autoStart = true;

    config = { config, pkgs, ... }: {

      services.gitea = {
        enable = true;
        settings = {
          session.COOKIE_SECURE = true;
          service.DISABLE_REGISTRATION = true;
          actions.ENABLED = true;
          server = {
            DOMAIN = "bonus.p4";
            SSH_PORT = 2222;
            ROOT_URL = "https://git.bonus.p4";
            HTTP_ADDRESS = "127.0.0.1";
          };
        };
        lfs.enable = true;
        appName = "Bonus's git";
      };

      system.stateVersion = "22.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ config.services.gitea.settings.server.HTTP_PORT config.services.gitea.settings.server.SSH_PORT ];
      };
    };
  };
}
