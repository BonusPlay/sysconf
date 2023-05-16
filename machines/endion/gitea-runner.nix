{ config, ... }:
let
  tokenFile = "/run/giteaToken";
in
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0400";
    owner = "gitea-runner";
  };

  containers.gitea-runner = {
    autoStart = true;
    bindMounts."${tokenFile}" = {
      hostPath = config.age.secrets.giteaRunnerLinuxToken.path;
      isReadOnly = true;
    };

    config = { config, pkgs, ... }: {
      services.gitea-actions-runner.instances.linux_amd64 = {
        enable = true;
        url = "https://git.bonus.p4";
        tokenFile = tokenFile;
        labels = [ "linux_amd64:host" ];
      };

      system.stateVersion = "unstable";
      networking.firewall = {
        enable = true;
      };
    };
  };
}
