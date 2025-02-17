{ lib, config, pkgs, home-manager, ... }:
{
  imports = [
    #./hardware-configuration.nix
    ./bridge.nix
    ./dhcp.nix
    ./dns.nix
    ./firewall.nix
    ./zerotier.nix
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "warpgate";
    nameservers = [ "1.1.1.1" ];

    # use nftables
    nat.enable = false;
    firewall.enable = false;
    nftables.enable = true;
  };

  boot.loader.grub.device = "/dev/sda";

  systemd.network.networks."10-wan" = {
    matchConfig.MACAddress = "20:7c:14:f2:9b:cf";
    networkConfig.DHCP = "yes";
  };

  # we use nf_tables
  boot.blacklistedKernelModules = [ "ip_tables" ];

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = false;

    # By default, don't configure automatically any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    ## On WAN, allow IPv6 autoconfiguration and tempory address use.
    #"net.ipv6.conf.${name}.accept_ra" = 2;
    #"net.ipv6.conf.${name}.autoconf" = 1;
  };
}
