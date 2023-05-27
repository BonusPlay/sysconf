{ config, ... }:
let
  tokenFile = "/var/lib/gitea-runner/token";
in
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0444";
  };

  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  containers.gitea-runner = {
    autoStart = true;
    bindMounts.runnerToken = {
      hostPath = config.age.secrets.giteaRunnerLinuxToken.path;
      mountPoint = tokenFile;
      isReadOnly = true;
    };

    config = { config, pkgs, ... }: {
      services.gitea-actions-runner.instances.linux_amd64 = {
        enable = true;
        name = "linux_amd64";
        url = "https://git.bonus.p4";
        tokenFile = tokenFile;
        labels = [ "linux_amd64:host" ];
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
      };
    };
  };
}
