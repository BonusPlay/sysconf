{ config, pkgs, lib, ... }:
{
  age.secrets.taigaEnv = {
    file = ../../secrets/taiga-env.age;
    mode = "0400";
  };

  age.secrets.taigaPass = {
    file = ../../secrets/cloudflare/taiga-tunnel.age;
    mode = "0440";
    group = "cloudflared";
  };

  services.cloudflared.tunnels."c37a8bd7-f81c-49a6-a290-b08dcaa1e0c5" = {
    credentialsFile = config.age.secrets.taigaPass.path;
    default = "http_status:404";
    ingress = {
      "taiga.kncyber.pl" = {
        service = "http://localhost:9000";
      };
    };
  };
}
