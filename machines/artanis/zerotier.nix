{ config, ... }:
{
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" "93afae59633bb8b8" ];
  };

  system.activationScripts.bonus = ''
    echo "b15644912e097589=p4net" > /var/lib/zerotier-one/devicemap;
    echo "93afae59633bb8b8=kncyber" >> /var/lib/zerotier-one/devicemap;
  '';

  systemd.network = {
    #networks."50-zerotier" = {
    #  name = "p4net";
    #  dns = [ "198.18.66.1" ];
    #  domains = [ "p4" ];
    #  networkConfig = {
    #    DNSSEC = false;
    #  };
    #};
    wait-online.ignoredInterfaces = [ "p4net" "kncyber" ];
  };
}
