{
  imports = [
    ./hardware-configuration.nix
    ./sabnzbd.nix
    ./transport.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = true;
    };
    warp-net.enable = true;
    monitoring.enable = true;
    traefik = {
      enable = true;
      entries = [];
    };
  };

  networking = {
    hostName = "moria";
    bridges.br-mullvad.interfaces = [ "enp6s19" ];
  };
}
