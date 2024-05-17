{ config, ... }:
{
  services.caddy.virtualHosts.forgejo = {
    listenAddresses = [ "100.99.52.31" ];
    hostName = "git.warp.lan";
    extraConfig = ''
      tls {
        curves secp384r1
        key_type p384
        issuer acme {
          dir https://pki.warp.lan/acme/warp/directory
          email acme@git.warp.lan
          trusted_roots ${../../files/warp-net-root.crt}
          disable_tlsalpn_challenge
        }
      }
      reverse_proxy http://${config.services.forgejo.settings.server.HTTP_ADDRESS}:${toString config.services.forgejo.settings.server.HTTP_PORT}
    '';
  };

  services.forgejo = {
    enable = true;
    settings = {
      session.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
      actions.ENABLED = true;
      repository.DEFAULT_BRANCH = "master";
      DEFAULT.APP_NAME = "Bonus's git";
      server = {
        DOMAIN = "mlwr.dev";
        SSH_PORT = 2222;
        ROOT_URL = "https://git.mlwr.dev";
        HTTP_ADDRESS = "127.0.0.1";
        START_SSH_SERVER = true;
      };
    };
    lfs.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];
}
