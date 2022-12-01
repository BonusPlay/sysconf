{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = "8080";
    serverUrl = "https://kaldir.bonusplay.pl";
    tls.letsencrypt.hostname = "*.bonusplay.pl";
    tls.letsencrypt.listen = ":8080";
  };
}
