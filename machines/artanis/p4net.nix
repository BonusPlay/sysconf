{ config, ... }:
{
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" ];
  };
}
