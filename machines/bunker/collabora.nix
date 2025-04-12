{ config, ... }:
{
  services.collabora-online = {
    enable = true;
    settings = {
      ssl.enable = false;
      ssl.termination = true;
      net = {
        listen = "0.0.0.0";
        post_allow = [ "127.0.0.1" "::1" ];
        lok_allow = [ "127.0.0.1" "::1" ];
      };
      storage.wopi = {
        "@allow" = true;
        host = [ "nextcloud.bonus.re" ];
      };
      remote_font_config.url = "https://nextcloud.bonus.re/apps/richdocuments/settings/fonts.json";
      server_name = "collabora.bonus.re";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.collabora-online.port ];
}
