{
  imports = [
    ./hardware-configuration.nix
    ./discord-bot.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "braxis";

  virtualisation = {
    docker.enable = true;
    oci-containers.backend = "docker";
  };

  services.cloudflared.enable = true;

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
