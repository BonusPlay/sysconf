{
  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };

  systemd.network = {
    netdevs = {
      "br-vms".netdevConfig = {
        Kind = "bridge";
        Name = "br-vms";
      };
      "br-mullvad".netdevConfig = {
        Kind = "bridge";
        Name = "br-mullvad";
      };
      "br-danger".netdevConfig = {
        Kind = "bridge";
        Name = "br-danger";
      };
    };
    networks = {
      "br-vms" = {
        name = "br-vms";
        address = [ "192.168.50.1/24" ];
      };
    };
  };

  # masquerade from br-vms to wlan0
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i br-vms -o wlan0 -j ACCEPT
  '';

  #networking = {
  #    dhcpcd.denyInterfaces = [ "br-vms" ];
  #    bridges = {
  #        "br-vms".interfaces = [];
  #    };
  #};
}
