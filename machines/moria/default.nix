{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
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

  networking.hostName = "moria";
  systemd.network.networks."10-wired" = {
    matchConfig.Name = "enp6s18";
    networkConfig.DHCP = "yes";
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  virtualisation = {
    containers = {
      enable = true;
      # https://github.com/containers/netavark/issues/339#issuecomment-2080432677
      #containersConf.settings.network.firewall_driver = "none";
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
