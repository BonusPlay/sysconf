{
  services.homebox.enable = true;

  custom.nginx.entries = [
    {
      entrypoints = [ "100.112.114.72" ];
      domain = "homebox.warp.lan";
      port = 7745;
    }
  ];
}
