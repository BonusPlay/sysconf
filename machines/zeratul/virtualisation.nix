{
  virtualisation.docker.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    allowedBridges = [ "br-vms" "br-host" ];
  };

  systemd.network.wait-online.ignoredInterfaces = [ "br-vms" "br-host" ];

  # required for VMs to use tunelling
  # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
  networking.firewall.checkReversePath = "loose";
}
