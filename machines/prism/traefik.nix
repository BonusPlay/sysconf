{ config, lib, ... }:
let
  recursiveMerge = elements: lib.foldl' lib.recursiveUpdate {} elements;
  httpApps = [
    {
      domain = "homebox.bonus.re";
      target = "http://nexus.internal:7745";
    }
    {
      domain = "esphome.bonus.re";
      target = "http://nexus.internal:6052";
    }
    {
      domain = "nextcloud.bonus.re";
      target = "http://bunker.internal:80";
    }
    {
      domain = "collabora.bonus.re";
      target = "http://bunker.internal:9980";
    }
    {
      domain = "has.bonus.re";
      target = "http://nexus.internal:8123";
    }
    {
      name = "forgejo";
      domain = "git.bonus.re";
      target = "http://endion.internal:3000";
    }
    {
      domain = "alpha.bonus.re";
      target = "https://alpha.internal:8006";
      extra.services.alpha.loadBalancer.serversTransport = "https-insecure";
    }
    {
      domain = "bravo.bonus.re";
      target = "https://bravo.internal:8006";
      extra.services.bravo.loadBalancer.serversTransport = "https-insecure";
    }
    {
      domain = "charlie.bonus.re";
      target = "https://charlie.internal:8006";
      extra.services.charlie.loadBalancer.serversTransport = "https-insecure";
    }
    {
      name = "uptime-kuma";
      domain = "uptime.bonus.re";
      target = "https://uptime.warp.lan";
    }
    {
      domain = "transmission.bonus.re";
      target = "http://moria.internal:9091";
    }
    {
      domain = "radarr.bonus.re";
      target = "http://moria.internal:7878";
    }
    {
      domain = "sonarr.bonus.re";
      target = "http://moria.internal:8989";
    }
    {
      domain = "bazarr.bonus.re";
      target = "http://moria.internal:6767";
    }
    {
      domain = "prowlarr.bonus.re";
      target = "http://moria.internal:9696";
    }
    {
      domain = "overseerr.bonus.re";
      target = "http://moria.internal:5055";
    }
    {
      domain = "sabnzbd.bonus.re";
      target = "http://moria.internal:8080";
    }
    {
      domain = "plex.bonus.re";
      target = "http://moria.internal:32400";
    }
  ];
  tcpApps = [
    {
      name = "forgejo-ssh";
      domain = "git.bonus.re";
      target = "endion.bonus.re:2222";
    }
    {
      name = "mqtt";
      domain = "mqtt.bonus.re";
      target = "nexus.internal:1883";
    }
  ];
in
{
  services.traefik = {
    enable = true;
    environmentFiles = [ config.age.secrets.cloudflare.path ];
    staticConfigOptions = {
      api.insecure = true;
      entryPoints = {
        wan = {
          address = ":443";
          http.tls = {
            certResolver = "letsencrypt";
            domains = [{ main = "*.bonus.re"; }];
          };
          http3 = {};
        };
        forgejo-ssh.address = ":2222";
      };
      accessLog = {};
      certificatesResolvers.letsencrypt.acme = {
        email = "acme@bonus.re";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge.provider = "cloudflare";
      };
    };
    dynamicConfigOptions =
      let
        mkHttpEntry = entry: let
          nameFromDomain = builtins.head (lib.strings.splitString "." entry.domain);
          name = if (entry ? name) then entry.name else nameFromDomain;
          extra = if (entry ? extra) then entry.extra else {};
        in recursiveMerge [{
          routers."${name}" = {
            rule = "Host(`${entry.domain}`)";
            service = name;
            entrypoints = [ "wan" ];
          };
          services."${name}".loadBalancer.servers = [{
            url = entry.target;
          }];
        } extra ];
        httpEntries = (map mkHttpEntry httpApps) ++ [{
          routers.api = {
            rule = "Host(`traefik.bonus.re`)";
            service = "api@internal";
          };
        }];
        httpConfig = lib.foldl' lib.recursiveUpdate {} httpEntries;

        mkTcpEntry = entry: {
          routers."${entry.name}" = {
            rule = "HostSNI(`*`)";
            service = entry.name;
            entrypoints = [ entry.name ];
          };
          services."${entry.name}".loadBalancer.servers = [{
            address = entry.target;
          }];
        };
        tcpEntries = map mkTcpEntry tcpApps;
        tcpConfig = lib.foldl' lib.recursiveUpdate {} tcpEntries;
      in
      {
        http = httpConfig // {
          serversTransports.https-insecure.insecureSkipVerify = true;
        };
        tcp = tcpConfig;
        tls.options = {
          default = {
            minVersion = "VersionTLS13";
            sniStrict = true;
            clientAuth = {
              caFiles = [ "/etc/ssl/certs/warp-net.crt" ];
              clientAuthType = "RequireAndVerifyClientCert";
            };
          };
          nomtls = {
            minVersion = "VersionTLS13";
            sniStrict = true;
          };
        };
      };
  };

  age.secrets.cloudflare = {
    file = ../../secrets/cloudflare/bonus.re.age;
    mode = "0400";
    owner = "traefik";
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
