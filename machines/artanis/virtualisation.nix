{
  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    allowedBridges = [ "br-vms" "br-mullvad" "br-danger" ];
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
      "br-host".netdevConfig = {
        Kind = "bridge";
        Name = "br-host";
      };
    };
    networks = {
      "20-br-vms" = {
        name = "br-vms";
        address = [ "192.168.50.1/24" ];
      };
      "20-br-host" = {
        name = "br-host";
        address = [ "192.168.55.1/24" ];
      };
    };
  };

  networking.firewall.extraCommands = ''
    # masquerade from br-vms to wlan0
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i br-vms -o wlan0 -j ACCEPT
  '';

  systemd.network.wait-online.ignoredInterfaces = [ "br-vms" "br-host" ];
}
