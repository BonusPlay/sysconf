let
  SSH_PORT = 2222;
in
{
  # needs to be setup on host's iptables
  # TODO: replace with NAT ?
  networking.firewall.allowedTCPPorts = [ SSH_PORT ];

  containers.gitea = {
    autoStart = true;

    config = { config, pkgs, ... }: {
      services.gitea = {
        enable = true;
        settings = {
          session.COOKIE_SECURE = true;
          service.DISABLE_REGISTRATION = true;
          actions.ENABLED = true;
          repository.DEFAULT_BRANCH = "master";
          server = {
            DOMAIN = "mlwr.dev";
            SSH_PORT = SSH_PORT;
            ROOT_URL = "https://git.mlwr.dev";
            HTTP_ADDRESS = "127.0.0.1";
            START_SSH_SERVER = true;
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
