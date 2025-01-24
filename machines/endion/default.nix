{
  imports = [
    ./hardware-configuration.nix
    ./forgejo.nix
  ];

  boot.loader.grub.device = "/dev/sda";

  custom = {
    base = {
      enable = true;
      autoUpgrade = false;
    };
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    caddy.enable = true;
  };

  networking.hostName = "endion";

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
