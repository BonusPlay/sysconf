{ config, system, pkgs, ... }:
{
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" "93afae59633bb8b8" ];
  };

  systemd.services.zerotierone.postStart = let
    resolvectl = "${pkgs.systemd}/bin/resolvectl";
  in ''
    ${resolvectl} dns p4net 198.18.66.1
    ${resolvectl} domain p4net '~p4'
    ${resolvectl} dnssec p4net off
  '';

  system.activationScripts.bonus = ''
    echo "b15644912e097589=p4net" > /var/lib/zerotier-one/devicemap;
    echo "93afae59633bb8b8=kncyber" >> /var/lib/zerotier-one/devicemap;
  '';

  systemd.network = {
    wait-online.ignoredInterfaces = [ "p4net" "kncyber" ];
  };
}
