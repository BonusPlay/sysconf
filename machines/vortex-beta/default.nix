{
  imports = [
    ./hardware-configuration.nix
    ./garage.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

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

  networking.hostName = "vortex-beta";

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };
}
