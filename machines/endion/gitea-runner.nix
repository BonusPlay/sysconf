{ config, ... }:
let
  tokenFile = "/var/lib/gitea-runner/token";
in
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0444";
  };

  containers.gitea-runner = {
    autoStart = true;
    bindMounts.runnerToken = {
      hostPath = config.age.secrets.giteaRunnerLinuxToken.path;
      mountPoint = tokenFile;
      isReadOnly = true;
    };

    config = { config, pkgs, ... }: {
      security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

      virtualisation.docker = {
        enable = true;
        storageDriver = "btrfs";
      };

      services.gitea-actions-runner.instances.linux_amd64 = {
        enable = true;
        name = "linux_amd64";
        url = "https://git.bonus.p4";
        tokenFile = tokenFile;
        labels = [
          "linux_amd64:docker://alpine:3"
          "linux_amd64:docker://python:3"
          "linux_amd64:docker://debian:11"
        ];
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
      };
    };
  };
}
