{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./changedetection.nix
    #./archivebox.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    caddy.enable = true;
    warp-net.enable = true;
    monitoring.enable = true;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking = {
    hostName = "observer";
    nat = {
      enable = true;
      externalInterface = "enp6s19";
    };
  };
}
