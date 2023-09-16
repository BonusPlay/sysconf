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
      ExecStart = "${pkgs.writers.writeShellScript "netns-up" ''
        ${pkgs.iproute}/bin/ip netns add $1
        ${pkgs.utillinux}/bin/umount /var/run/netns/$1
        ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
      ''} %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  systemd.services.wireguard-mullvad = {
    bindsTo = [ "netns@mullvad.service" ];
    unitConfig.JoinsNamespaceOf = "netns@mullvad.service";
    serviceConfig.PrivateNetwork = true;
  };

  networking = {
    nameservers = [ "10.64.0.1" ];
    firewall.checkReversePath = "loose";
    wireguard.interfaces.mullvad = {
      interfaceNamespace = "mullvad";
      ips = [ "10.65.123.173/32" "fc00:bbbb:bbbb:bb01::2:7bac/128" ];
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];
          endpoint = "178.249.209.162:51820";
          publicKey = "5FZW+fNA2iVBSY99HFl+KjGc9AFVNE+UFAedLNhu8lc=";
        }
      ];
      privateKeyFile = config.age.secrets.mullvadPrivateKey.path;
    };
  };
}
