{ config, lib, ... }:
let
  plex = [
    {
      domain = "plex.bonus.re";
      target = "plex.internal";
      toPort = 32400;
      isPublic = true;
    }
  ];

  regular = [
    {
      domain = "homebox.bonus.re";
      target = "nexus.internal";
      toPort = 7745;
    }
    {
      domain = "esphome.bonus.re";
      target = "nexus.internal";
      toPort = 6052;
    }
    {
      domain = "nextcloud.bonus.re";
      target = "bunker.internal";
      toPort = 80;
    }
    {
      domain = "collabora.bonus.re";
      target = "bunker.internal";
      toPort = 9980;
    }
    {
      domain = "has.bonus.re";
      target = "nexus.internal";
      toPort = 8123;
    }
    {
      domain = "git.bonus.re";
      target = "endion.internal";
      toPort = 3000;
    }
    {
      domain = "transmission.bonus.re";
      target = "moria.internal";
      toPort = 9091;
    }
    {
      domain = "radarr.bonus.re";
      target = "moria.internal";
      toPort = 7878;
    }
    {
      domain = "sonarr.bonus.re";
      target = "moria.internal";
      toPort = 8989;
    }
    {
      domain = "bazarr.bonus.re";
      target = "moria.internal";
      toPort = 6767;
    }
    {
      domain = "prowlarr.bonus.re";
      target = "moria.internal";
      toPort = 9696;
    }
    {
      domain = "overseerr.bonus.re";
      target = "moria.internal";
      toPort = 5055;
      #authFile = config.age.secrets.auth-overseer.path;
    }
    {
      domain = "sabnzbd.bonus.re";
      target = "moria.internal";
      toPort = 8080;
    }
    {
      domain = "bitmagnet.bonus.re";
      target = "moria.internal";
      toPort = 3333;
    }
    {
      domain = "s3.bonus.re";
      target = "glacius.internal";
      toPort = 3900;
    }
    {
      domain = "ai-vmi.bonus.re";
      target = "10.20.0.22";
      toPort = 4096;
    }
  ];

  proxmox = [
    {
      domain = "alpha.bonus.re";
      target = "alpha.internal";
      toPort = 8006;
    }
    {
      domain = "bravo.bonus.re";
      target = "bravo.internal";
      toPort = 8006;
    }
    {
      domain = "charlie.bonus.re";
      target = "charlie.internal";
      toPort = 8006;
    }
  ];

  withBindPort = list: val: map (item: item // { bindPort = val; }) list;
  withProxyToHttps = list: map (item: item // {
    extraProxyConfig = ''
      transport http {
        tls
        tls_insecure_skip_verify
      }
    '';
  }) list;
in
{
  custom.caddy.entries = []
    ++ (withBindPort plex 441)
    ++ (withBindPort regular 442)
    ++ (withBindPort (withProxyToHttps proxmox) 442);

  networking.firewall.allowedTCPPorts = [ 441 442 ];
}
