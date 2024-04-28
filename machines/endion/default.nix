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
    base = {
      enable = true;
      autoUpgrade = false;
    };
    server = {
      enable = true;
      vm = true;
    };
    traefik = {
      enable = true;
      warpIP = "100.99.52.31";
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  networking.hostName = "endion";
}
