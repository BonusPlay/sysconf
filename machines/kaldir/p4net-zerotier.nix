{
  nixpkgs.config.allowUnfree = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" ];
  };

  system.activationScripts.bonus = let
    local = builtins.toJSON {
      settings = {
        interfacePrefixBlacklist = [ "p4net-" "ve-" ];
      };
    };
  in ''
    echo "b15644912e097589=p4net-khala" > /var/lib/zerotier-one/devicemap;
    cat << EOF > /var/lib/zerotier-one/local.conf
      ${local}
    EOF
  '';
}
