{ config, ... }:
let
  SSH_PORT = 2222;
in
{
  # needs to be setup on host's iptables
  # TODO: replace with NAT ?
  networking.firewall.allowedTCPPorts = [ SSH_PORT ];

  custom.traefik.entries = [
    {
      name = "git";
      domain = "git.mlwr.dev";
      port = config.containers.forgejo.config.services.forgejo.settings.server.HTTP_PORT;
      entrypoints = [ "warps" ];
    }
  ];

  containers.forgejo = {
    autoStart = true;

    config = { config, pkgs, ... }: {
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
            SSH_PORT = SSH_PORT;
            ROOT_URL = "https://git.mlwr.dev";
            HTTP_ADDRESS = "127.0.0.1";
            START_SSH_SERVER = true;
          };
        };
        lfs.enable = true;
      };

      system.stateVersion = "23.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ config.services.forgejo.settings.server.HTTP_PORT config.services.forgejo.settings.server.SSH_PORT ];
      };
    };
  };
}
