{
  services.minio = {
    enable = true;
    region = "eu-warp-1";
    dataDir = [ "/storage/minio" ];
  };

  systemd.services.minio.environment.MINIO_API_ROOT_ACCESS = "off";

  custom.caddy.entries = [
    {
      entrypoints = [ "100.101.16.57" ];
      domain = "s3.warp.lan";
      port = 9000;
    }
    {
      entrypoints = [ "100.101.16.57" ];
      domain = "minio.warp.lan";
      port = 9001;
    }
  ];
}
