{ config, ... }:
{
  custom.traefik.entries = [
    {
      name = "git";
      domain = "git.mlwr.dev";
      port = config.services.forgejo.settings.server.HTTP_PORT;
      entrypoints = [ "warps" ];
    }
  ];

  services.forgejo = {
    enable = true;
    settings = {
      session.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
      actions.ENABLED = true;
      repository.DEFAULT_BRANCH = "master";
      DEFAULT.APP_NAME = "Bonus's git";
      server = {
        DOMAIN = "mlwr.dev";
        SSH_PORT = 2222;
        ROOT_URL = "https://git.mlwr.dev";
        HTTP_ADDRESS = "127.0.0.1";
        START_SSH_SERVER = true;
      };
    };
    lfs.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];
}
