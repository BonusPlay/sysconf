let
  backbone = "52b337794f08427d";
  kncyber = "93afae59633bb8b8";
in
{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ backbone kncyber ];
  };

  system.activationScripts.bonus = let
    local = builtins.toJSON {
      settings = {
        interfacePrefixBlacklist = [ "br-" "docker0" ];
      };
    };
  in ''
    echo "${backbone}=backbone" > /var/lib/zerotier-one/devicemap;
    echo "${kncyber}=kncyber" >> /var/lib/zerotier-one/devicemap;
    cat << EOF > /var/lib/zerotier-one/local.conf
      ${local}
    EOF
  '';

  systemd.network.wait-online.ignoredInterfaces = [ "backbone" "kncyber" ];
}
