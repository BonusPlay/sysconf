{ config, pkgs, ... }:
let
  lanIface = "ens19";
  vpnIface = "mullvad";
in
{
  age.secrets.mullvadPrivateKey = {
    file = ../../secrets/mullvad/vanass.age;
    mode = "0400";
  };

  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writeShellScript "netns-up" ''
        ${pkgs.iproute}/bin/ip netns add $1
        ${pkgs.utillinux}/bin/umount /var/run/netns/$1
        ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
        ${pkgs.iproute}/bin/ip link set ${lanIface} netns $1
      ''} %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  #systemd.services.wireguard-mullvad = {
  #  bindsTo = [ "netns@mullvad.service" ];
  #  unitConfig.JoinsNamespaceOf = "netns@mullvad.service";
  #  serviceConfig.PrivateNetwork = true;
  #};

  environment.etc."netns/mullvad/resolv.conf".text = "nameserver 10.64.0.1";

  networking = {
    firewall.checkReversePath = "loose";
    wireguard.interfaces.${vpnIface} = {
      interfaceNamespace = "mullvad";
      ips = [ "10.64.92.80/32" "fc00:bbbb:bbbb:bb01::1:5c4f/128" ];
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];
          endpoint = "185.65.135.72:51820";
          publicKey = "5rVa0M13oMNobMY7ToAMU1L/Mox7AYACvV+nfsE7zF0=";
        }
      ];
      privateKeyFile = config.age.secrets.mullvadPrivateKey.path;
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i ${lanIface} -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${vpnIface} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i ${lanIface} -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ${vpnIface} -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i ${lanIface} -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${vpnIface} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i ${lanIface} -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -o ${vpnIface} -j MASQUERADE
      '';
    };
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [
        lanIface
      ];
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [ { pool = "192.168.15.100 - 192.168.15.240"; } ];
          subnet = "192.168.15.0/24";
        }
      ];
      valid-lifetime = 4000;
    };
  };

  # additional kea config
  systemd.services.kea-dhcp4-server = {
    bindsTo = [ "netns@mullvad.service" ];
    unitConfig.JoinsNamespaceOf = "netns@mullvad.service";
    serviceConfig.PrivateNetwork = true;
  };
}
