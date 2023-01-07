{
  services.keycloak = {
    enable = true;
    settings = {
      hostname = "keycloak.kncyber.pl";
      proxy = "edge";
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {

    };
  };
}
