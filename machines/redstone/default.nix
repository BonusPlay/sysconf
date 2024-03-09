{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  custom = {
    base.enable = true;
    server = {
      enable = true;
      vm = false;
    };
    warp-net.enable = true;
    monitoring.enable = true;
  };

  services.fwupd.enable = true;

  hardware.raspberry-pi."4".fkms-3d.enable = true;
  virtualisation.waydroid.enable = true;

  # boot.loader handled by nixos-hardware
}
