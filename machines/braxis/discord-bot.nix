{ config, ... }:
{
  age.secrets.discord-bot = {
    file = ../../secrets/kncyber/discord-bot.age;
    mode = "0400";
  };

  virtualisation.oci-containers.containers = {
    discordbot = {
      image = "ghcr.io/kncyber/welcome-bot:latest";
      environmentFiles = [ config.age.secrets.discord-bot.path ];
    };
  };
}
