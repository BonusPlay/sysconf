{ config, pkgs, ... }:
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0444";
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.linux_amd64 = {
      enable = true;
      name = "x_linux_amd64";
      url = "https://git.mlwr.dev";
      tokenFile = config.age.secrets.giteaRunnerLinuxToken.path;
      labels = [
        "linux_amd64:docker://node:16-bullseye"
      ];
    };
  };
}
