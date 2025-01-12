{
  systemd.network = {
    networks = {
      "10-wired" = {
        matchConfig.Name = "enp6s18";
        networkConfig.DHCP = "yes";
      };
      "20-vpn" = {
        matchConfig.Name = "enp6s19";
        networkConfig.Bridge = "br-mullvad";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-bridge" = {
        matchConfig.Name = "br-mullvad";
        networkConfig.LinkLocalAddressing = "no";
        linkConfig.RequiredForOnline = "carrier";
      };
    };
    netdevs.br-mullvad = {
      enable = true;
      netdevConfig = {
        Kind = "bridge";
        Name = "br-mullvad";
      };
    };
  };
}
