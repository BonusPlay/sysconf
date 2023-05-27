{ config, ... }:
{
  age.secrets.giteaRunnerLinuxToken = {
    file = ../../secrets/gitea-runner-linux-token.age;
    mode = "0444";
  };

  age.secrets.dockerRegistryCreds = {
    file = ../../secrets/dr-bonus-p4-services.age;
    mode = "0400";
    path = "/root/.docker/config.json";
  };

  # hack to downlaod image to node
  system.activationScripts.pullDockerImages = ''
    docker pull dr.bonusplay.pl/p4net/node:16-bullseye
  '';

  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  services.gitea-actions-runner.instances.linux_amd64 = {
    enable = true;
    name = "linux_amd64";
    url = "https://git.bonus.p4";
    tokenFile = config.age.secrets.giteaRunnerLinuxToken.path;
    labels = [
      "linux_amd64:docker://dr.bonusplay.pl/p4net/node:16-bullseye"
    ];
  };
}
