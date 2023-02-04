{
  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    allowedBridges = [ "br-vms" "br-mullvad" "br-danger" "br-host" ];
  };

  networking.firewall.extraCommands = ''
    # masquerade from br-vms to wlp166s0
    iptables -t nat -A POSTROUTING -o wlp166s0 -j MASQUERADE
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i br-vms -o wlp166s0 -j ACCEPT
  '';

  systemd.network.wait-online.ignoredInterfaces = [ "br-vms" "br-host" ];
}
