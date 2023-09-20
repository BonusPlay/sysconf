{ config, pkgs, lib, ... }:
let
  lanIface = "ens19";
  vpnIface = "mullvad";

  netNs = "mullvad";

  execInNs = cmd: "${pkgs.iproute}/bin/ip netns exec ${netNs} ${cmd}";
  execBatchInNs = lines: lib.strings.concatStringsSep "\n" (map execInNs lines);
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
      ''} %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  boot.kernel.sysctl = {
    net.ipv4.ip_forward = 1;
  };

  # dummy to start netns
  systemd.services.netns-init = {
    bindsTo = [ "netns@${netNs}.service" ];
    wantedBy = [ "wireguard-${vpnIface}.service" ];
    unitConfig.JoinsNamespaceOf = "netns@${netNs}.service";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writeShellScript "netns-init" ''
        echo Starting netns ${netNs}
      ''}";
    };
  };

  # move lanIface to netns
  systemd.services.netns-iface = {
    after = [ "netns-init.service" ];
    wantedBy = [ "kea-dhcp4-server.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.iproute}/bin/ip link set ${lanIface} netns ${netNs}";
      ExecStart = "${pkgs.writeShellScript "netns-iface" (execBatchInNs [
        "${pkgs.iproute}/bin/ip link set dev ${lanIface} up"
        "${pkgs.iproute}/bin/ip addr add dev ${lanIface} 192.168.60.1/24"
      ])}";
    };
  };

  #systemd.services.wireguard-mullvad = {
  #  bindsTo = [ "netns@mullvad.service" ];
  #  unitConfig.JoinsNamespaceOf = "netns@mullvad.service";
  #  serviceConfig.PrivateNetwork = true;
  #};

  environment.etc."netns/${netNs}/resolv.conf".text = "nameserver 10.64.0.1";

  networking = {
    firewall.checkReversePath = "loose";
    wireguard.interfaces.${vpnIface} = {
      interfaceNamespace = netNs;
      ips = [ "10.64.92.80/32" "fc00:bbbb:bbbb:bb01::1:5c4f/128" ];
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];
          endpoint = "185.65.135.72:51820";
          publicKey = "5rVa0M13oMNobMY7ToAMU1L/Mox7AYACvV+nfsE7zF0=";
        }
      ];
      privateKeyFile = config.age.secrets.mullvadPrivateKey.path;
      postSetup = execBatchInNs [
        "${pkgs.iptables}/bin/iptables -A FORWARD -i ${lanIface} -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${vpnIface} -j MASQUERADE"
        "${pkgs.iptables}/bin/ip6tables -A FORWARD -i ${lanIface} -j ACCEPT"
        "${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ${vpnIface} -j MASQUERADE"
      ];
      postShutdown = execBatchInNs [
        "${pkgs.iptables}/bin/iptables -D FORWARD -i ${lanIface} -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${vpnIface} -j MASQUERADE"
        "${pkgs.iptables}/bin/ip6tables -D FORWARD -i ${lanIface} -j ACCEPT"
        "${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -o ${vpnIface} -j MASQUERADE"
      ];
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
    bindsTo = [ "netns@${netNs}.service" ];
    unitConfig.JoinsNamespaceOf = "netns@${netNs}.service";
    serviceConfig = {
      PrivateNetwork = true;
    };
  };
}
