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
        ROOT_URL = "https://git.bonus.re";
        HTTP_ADDRESS = "0.0.0.0";
        START_SSH_SERVER = true;
      };
    };
    lfs.enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    config.services.forgejo.settings.server.SSH_PORT
    config.services.forgejo.settings.server.HTTP_PORT
  ];
}
