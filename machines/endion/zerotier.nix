{
  nixpkgs.config.allowUnfree = true;
  security.pki.certificates = [ (builtins.readFile ../../files/p4net/p4net-ca.crt) ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" ];
  };

  system.activationScripts.bonus = ''
    echo "b15644912e097589=p4net" > /var/lib/zerotier-one/devicemap;
  '';
}
