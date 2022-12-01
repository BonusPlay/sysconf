{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    serverUrl = "https://kaldir.bonusplay.pl";
    tls.letsencrypt.hostname = "*.bonusplay.pl";
  };
}
