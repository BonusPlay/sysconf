{ config, ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  services.gitea-actions-runner.instances.linux_amd64 = {
    enable = true;
    name = "linux_amd64";
    url = "https://git.mlwr.dev";
    tokenFile = config.age.secrets.giteaRunnerLinuxToken.path;
    labels = [
      "linux_amd64:docker://node:16-bullseye"
    ];
  };
}
