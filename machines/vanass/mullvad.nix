{ config, pkgs, ... }:
{
  age.secrets.mullvadPrivateKey = {
    file = ../../secrets/mullvad/vanass.age;
    mode = "0400";
  };

  networking.nameservers = [ "10.64.0.1" ];

  networking.wireguard.interfaces.mullvad = {
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
}
