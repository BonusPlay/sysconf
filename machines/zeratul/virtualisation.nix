{
  virtualisation.docker.enable = true;

  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = [ "amd_iommu=on" ];
  };

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    allowedBridges = [ "br-nat" "br-host" ];
  };

  systemd.network.wait-online.ignoredInterfaces = [ "br-nat" "br-host" ];

  # required for VMs to use tunelling
  # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
  networking.firewall.checkReversePath = "loose";
}
