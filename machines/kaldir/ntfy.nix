{ config, ... }:
let
  dataDir = "/var/lib/ntfy-sh";
  domain = "ntfy.bonus.re";
  port = 4050;
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":${toString port}";
      base-url = "https://${domain}";
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
      domain = domain;
      port = port;
    }
  ];
}
