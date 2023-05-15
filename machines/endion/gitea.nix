{
  containers.gitea = {
    autoStart = true;

    config = { config, pkgs, ... }: {

      services.gitea = {
        enable = true;
        useWizard = true;
        settings = {
          session.COOKIE_SECURE = true;
          service.DISABLE_REGISTRATION = true;
          server.SSH_PORT = 2222;
        };
        rootUrl = "https://git.bonus.p4";
        lfs.enable = true;
        httpAddress = "127.0.0.1";
        domain = "bonus.p4";
        appName = "Bonus's git";
      };

      system.stateVersion = "22.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
    };
  };
}
