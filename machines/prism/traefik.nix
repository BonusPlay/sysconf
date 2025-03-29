{ config, lib, ... }:
let
  recursiveMerge = elements: lib.foldl' lib.recursiveUpdate {} elements;
  httpApps = [
    {
      domain = "homebox.bonus.re";
      target = "http://bunker.internal:7745";
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
  ];
  tcpApps = [
    {
      name = "forgejo-ssh";
      domain = "git.bonus.re";
      target = "endion.bonus.re:2222";
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
        httpEntries = map mkHttpEntry httpApps;
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
        tls.options.default = {
          minVersion = "VersionTLS13";
          sniStrict = true;
          clientAuth = {
            caFiles = [ "/etc/ssl/certs/warp-net.crt" ];
            clientAuthType = "RequireAndVerifyClientCert";
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
