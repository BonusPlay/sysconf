{
  imports = [
    ./hardware-configuration.nix
    ./gitea-runner.nix
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
  };

  networking.hostName = "shakuras";

  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp0s18";
    networkConfig.DHCP = "yes";
  };
}
