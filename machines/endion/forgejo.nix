{ config, ... }:
{
  services.forgejo = {
    enable = true;
    settings = {
      session.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
      actions.ENABLED = true;
      repository.DEFAULT_BRANCH = "master";
      DEFAULT.APP_NAME = "Bonus's git";
      server = {
        DOMAIN = "warp.lan";
        SSH_PORT = 2222;
        ROOT_URL = "https://git.warp.lan";
        HTTP_ADDRESS = "127.0.0.1";
        START_SSH_SERVER = true;
      };
    };
    lfs.enable = true;
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.99.52.31" ];
      domain = "git.warp.lan";
      target = config.services.forgejo.settings.server.HTTP_ADDRESS;
      port = config.services.forgejo.settings.server.HTTP_PORT;
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];
}
