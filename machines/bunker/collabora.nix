{ config, ... }:
{
  services.collabora-online = {
    enable = true;
    settings = {
      ssl.enable = false;
      ssl.termination = true;
      net = {
        listen = "127.0.0.1";
        post_allow = [ "127.0.0.1" "::1" ];
        lok_allow = [ "127.0.0.1" "::1" ];
      };
      storage.wopi = {
        "@allow" = true;
        host = [ "nextcloud.warp.lan" ];
      };
      remote_font_config.url = "https://nextcloud.warp.lan/apps/richdocuments/settings/fonts.json";
      server_name = "collabora.warp.lan";
    };
  };

  custom.nginx.entries = [
    {
      entrypoints = [ "0.0.0.0" ];
      domain = config.services.collabora-online.settings.server_name;
      port = config.services.collabora-online.port;
    }
  ];
}
