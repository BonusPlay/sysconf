{
  imports = [
    ./hardware-configuration.nix
    ./authentik.nix
  ];

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

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };

  networking.hostName = "depot";

  # no clue why server can't connect to itself over tailscale ip
  # so this is a workaround
  networking.hosts = {
    "127.0.0.1" = [ "auth.warp.lan" ];
  };
}
