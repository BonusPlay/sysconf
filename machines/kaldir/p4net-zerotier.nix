{
  nixpkgs.config.allowUnfree = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" ];
  };

  system.activationScripts.bonus = ''
    echo "b15644912e097589=p4net-khala" > /var/lib/zerotier-one/devicemap;
  '';
}
