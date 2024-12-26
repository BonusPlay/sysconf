{
  imports = [
    ./hardware-configuration.nix
    ./forgejo.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  custom = {
    base.enable = true;
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
    matchConfig.Name = "enp0s18";
    networkConfig.DHCP = "yes";
  };
}
