{ config, ... }:
{
  age.secrets.obsidian-env = {
    file = ../../secrets/obsidian-env.age;
    mode = "0600";
    owner = "106"; # hope this works?
  };

  # sadly, it seems like obsidian doesn't trust custom CA
  # https://github.com/vrtmrz/obsidian-livesync/issues/12
  # https://github.com/vrtmrz/obsidian-livesync/issues/37
  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "obsidian.bonusplay.pl";
      target = config.containers.obsidian.localAddress;
      port = config.containers.obsidian.config.services.couchdb.port;
      extraConfig = ''
        @allowedOrigin expression `
          {http.request.header.Origin}.matches('^app://obsidian.md$') ||
          {http.request.header.Origin}.matches('^capacitor://localhost$') ||
          {http.request.header.Origin}.matches('^http://localhost$')
        `

        header {
          Access-Control-Allow-Origin {http.request.header.Origin}
          Access-Control-Allow-Methods "GET, PUT, POST, HEAD, DELETE"
          Access-Control-Allow-Headers "accept, authorization, content-type, origin, referer"
          Access-Control-Allow-Credentials "true"
          Access-Control-Max-Age "3600"
          Vary "Origin"
          defer
        }
      '';
    }
  ];

  containers.obsidian = let
    obsidianEnvFile = "/run/obsidian-env";
  in {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.5.1";
    localAddress = "172.28.5.2";
    bindMounts.obsidian-env = {
      hostPath = config.age.secrets.obsidian-env.path;
      mountPoint = obsidianEnvFile;
      isReadOnly = false;
    };

    config = { config, ... }: {
      services.couchdb = {
        enable = true;
        bindAddress = "0.0.0.0";
        configFile = obsidianEnvFile;
        # https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md#configure
        extraConfig = ''
          [couchdb]
          single_node=true
          max_document_size = 50000000

          [chttpd]
          require_valid_user = true
          max_http_request_size = 4294967296
          enable_cors = true

          [chttpd_auth]
          require_valid_user = true
          authentication_redirect = /_utils/session.html

          [httpd]
          WWW-Authenticate = Basic realm="couchdb"

          [cors]
          origins = app://obsidian.md, capacitor://localhost, http://localhost
          credentials = true
          headers = accept, authorization, content-type, origin, referer
          methods = GET,PUT,POST,HEAD,DELETE
          max_age = 3600
        '';
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ config.services.couchdb.port ];
      };

      system.stateVersion = "23.11";
    };
  };
}
