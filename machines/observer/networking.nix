{ pkgs, ... }:
{
  systemd.network = {
    networks = {
      "10-wired" = {
        matchConfig.Name = "enp6s18";
        networkConfig.DHCP = "yes";
      };
      "20-ignore-vpn" = {
        matchConfig.Name = "enp6s19";
        linkConfig.RequiredForOnline = "no";
        linkConfig.Unmanaged = "yes";
      };
    };
  };

  systemd.services."podman-macvlan" = {
    description = "setup podman macvlan";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network exists mullvad_macvlan || \
      ${pkgs.podman}/bin/podman network create \
        --driver=macvlan \
        -o parent=enp6s19 \
        mullvad_macvlan
    '';
  };
}
