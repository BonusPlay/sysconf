{
  imports = [
    ./hardware-configuration.nix
    ./authentik.nix
  ];

  custom = {
    base = {
      enable = true;
      autoUpgrade = true;
    };
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    caddy.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "depot";
}
