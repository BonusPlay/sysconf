{ config, ... }:
let
  hostIP = "172.28.5.1";
  containerIP = "172.28.5.2";
  port = config.containers.obsidian.config.services.couchdb.port;
  middleware = {
    obsidiancors.headers = {
      accessControlAllowMethods = [ "GET" "PUT" "POST" "HEAD" "DELETE" ];
      accessControlAllowHeaders = [ "accept" "authorization" "content-type" "origin" "referer" ];
      accessControlAllowOriginList = [ "app://obsidian.md" "capacitor://localhost" "http://localhost" ];
      accessControlMaxAge = 3600;
      addVaryHeader = true;
      accessControlAllowCredentials = true;
    };
  };
  obsidianEnvFile = "/run/obsidian-env";
in
{
  age.secrets.obsidian-env = {
    file = ../../secrets/obsidian-env.age;
    mode = "0600";
    owner = "couchdb";
  };

  custom.traefik.entries = [
    {
      name = "obsidian";
      domain = "obsidian.bonusplay.pl";
      target = config.containers.obsidian.localAddress;
      port = port;
      entrypoints = [ "webs" ];
      middlewares = [ middleware ];
    }
  ];

  containers.obsidian = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;
    bindMounts.obsidian-env = {
      hostPath = config.age.secrets.obsidian-env.path;
      mountPoint = obsidianEnvFile;
      isReadOnly = true;
    };

    config = { config, ... }: {
      services.couchdb = {
        enable = true;
        bindAddress = containerIP;
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
        allowedTCPPorts = [ port ];
      };

      system.stateVersion = "23.11";
    };
  };
}
