{ config, ... }:
let
  dataDir = "/var/lib/ntfy-sh";
  port = 4050;
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":${toString port}";
      base-url = "https://ntfy.warp.lan";
      auth-file = "${dataDir}/auth.db";
      auth-default-access = "deny-all";
      behind-proxy = true;
      attachment-cache-dir = "${dataDir}/attachments";
      cache-file = "${dataDir}/cache-file.db";
      enable-login = true;
    };
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "100.98.118.66" ];
      domain = config.services.ntfy-sh.settings.base-url;
      port = port;
    }
  ];
}
