{ config, ... }:
{
  age.secrets.discord-bot = {
    file = ../../secrets/discord-bot.age;
    mode = "0400";
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  virtualisation.oci-containers.containers = {
    discordbot = {
      image = "ghcr.io/kncyber/welcome-bot:latest";
      environmentFiles = [ config.age.secrets.discord-bot.path ];
    };
  };
}
