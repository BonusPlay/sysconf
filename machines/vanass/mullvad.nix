{ config, pkgs, ... }:
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

  #systemd.services.wireguard-mullvad = {
  #  bindsTo = [ "netns@mullvad.service" ];
  #  unitConfig.JoinsNamespaceOf = "netns@mullvad.service";
  #  serviceConfig.PrivateNetwork = true;
  #};

  environment.etc."netns/mullvad/resolv.conf".text = "nameserver 10.64.0.1";

  networking = {
    firewall.checkReversePath = "loose";
    wireguard.interfaces.mullvad = {
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
    };
  };
}
