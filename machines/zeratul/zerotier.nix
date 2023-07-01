{ config, system, pkgs, ... }:
{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "52b337794f08427d" ];
  };

  system.activationScripts.bonus = let
    local = builtins.toJSON {
      settings = {
        interfacePrefixBlacklist = [ "br-" "docker0" ];
      };
    };
  in ''
    echo "52b337794f08427d=warp-net" > /var/lib/zerotier-one/devicemap;
    cat << EOF > /var/lib/zerotier-one/local.conf
      ${local}
    EOF
  '';

  systemd.network = {
    wait-online.ignoredInterfaces = [ "warp-net" ];
  };
}