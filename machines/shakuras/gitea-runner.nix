{ config, ... }:
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0444";
  };

  age.secrets.dockerRegistryCreds = {
    file = ../../secrets/docker-registry-service-account.age;
    mode = "0400";
    path = "/root/.docker/config.json";
  };

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
