{ lib, config, ... }:
let
  # some of this config is stole from:
  # https://github.com/oddlama/nix-config/blob/main/hosts/envoy/stalwart-mail.nix
  mainDomain = "mail.bonusplay.pl";
  domains = [
    "mail.mlwr.dev"
  ] ++ [ mainDomain ];
  dataDir = "/var/lib/stalwart/data";
in
{
  services.stalwart-mail = {
    enable = true;
    openFirewall = true;
    settings = let
      is-smtp = data: {
        "if" = "listener = 'smtp'";
        "then" = data;
      };
      is-authenticated = data: {
        "if" = "!is_empty(authenticated_as)";
        "then" = data;
      };
      is-local-domain = data: {
        "if" = "is_local_domain('', sender_domain)";
        then = data;
      };
      otherwise = value: { "else" = value; };
    in {
      server = {
        hostname = mainDomain;
        listener = {
          smtp = {
            bind = ["[::]:25"];
            protocol = "smtp";
          };
          submissions = {
            bind = ["[::]:465"];
            protocol = "smtp";
            tls.implicit = true;
          };
          submission = {
            bind = ["[::]:587"];
            protocol = "smtp";
          };
          imaptls = {
            bind = ["[::]:993"];
            protocol = "imap";
            tls.implicit = true;
          };
          http = {
            # jmap, web interface
            protocol = "http";
            bind = "[::]:8080";
            url = "https://${mainDomain}";
            use-x-forwarded = true;
          };
        };
        tls = {
          certificate = "default";
          ignore-client-order = true;
        };
        socket = {
          nodelay = true;
          reuse-addr = true;
        };
      };

      session = {
        ehlo = {
          require = true;
          reject-non-fqdn = [
            (is-smtp true)
            (otherwise false)
          ];
        };
        rcpt = {
          catch-all = true;
          max-recipients = 25;
          script = "multibox";
        };
        extensions = {
          pipelining = true;
          chunking = true;
          requiretls = true;
          no-soliciting = "";
          dsn = false;
          expn = [
            (is-authenticated true)
            (otherwise false)
          ];
          vrfy = [
            (is-authenticated true)
            (otherwise false)
          ];
          future-release = [
            (is-authenticated "30d")
            (otherwise false)
          ];
          deliver-by = [
            (is-authenticated "365d")
            (otherwise false)
          ];
          mt-priority = [
            (is-authenticated "mixer")
            (otherwise false)
          ];
        };
      };

      auth = {
        dmarc.verify = [
          (is-smtp "strict")
          (otherwise "disable")
        ];
        spf.verify = {
          ehlo = [
            (is-smtp "relaxed")
            (otherwise "disable")
          ];
          mail-from = [
            (is-smtp "relaxed")
            (otherwise "disable")
          ];
        };
        auth.arc.verify = "strict";
        dkim.sign = [ 
          (is-local-domain "'rsa_' + sender_domain")
          (otherwise = false)
        ];
        dkim.verify = "relaxed";
      };

      storage = {
        data = "rocksdb";
        fts = "rocksdb";
        blob = "rocksdb";
        lookup = "rocksdb";
        directory = "internal";
        encryption = {
          enable = true;
          append = true;
        };
      };

      certificate.default = lib.mergeAttrsList (map (domain: {
        ${domain} = {
          cert = "%{file:${config.security.acme.certs.${domain}.directory}/fullchain.pem}%";
          private-key = "%{file:${config.security.acme.certs.${domain}.directory}/key.pem}%";
          default = domain == mainDomain;
        };
      }) domains);

      signature = lib.mergeAttrsList (map (domain: {
        rsa = {
          private-key = "%{file:${dataDir}/dkim/${domain}-rsa.key}%";
          domain = "bonusplay.pl";
          selector = "rsa-default";
          headers = ["From", "To", "Cc", "Date", "Subject", "Message-ID", "Organization", "MIME-Version", "Content-Type", "In-Reply-To", "References", "List-Id", "User-Agent", "Thread-Topic", "Thread-Index"];
          algorithm = "rsa-sha256";
          canonicalization = "relaxed/relaxed";
          expire = "10d";
          set-body-length = false;
          report = true;
        };
        ed25519 = {
          private-key = "%{file:${dataDir}/dkim/${domain}-ed25519.key}%";
          domain = "bonusplay.pl";
          selector = "ed-default";
          headers = ["From", "To", "Cc", "Date", "Subject", "Message-ID", "Organization", "MIME-Version", "Content-Type", "In-Reply-To", "References", "List-Id", "User-Agent", "Thread-Topic", "Thread-Index"];
          algorithm = "ed25519-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = false;
          report = false;
        };
      }) domains);

      store."rocksdb" = {
        type = "rocksdb";
        path = "${dataDir}/store";
        compression = "lz4";
      };

      directory."internal" = {
        type = "internal";
        store = "rocksdb";
      };

      tracer."stdout" = {
        type = "stdout";
        level = "info";
        ansi = false;
        enable = true;
      };

      authentication.fallback-admin = {
        user = "admin";
        secret = "%{env:ADMIN_SECRET}%";
      };

      sieve.trusted.scripts.multibox = "%{file:${config.secrets.sieve-multibox.path}}%";
    };
  };

  age.secrets.sieve-multibox = {
    file = ../../secrets/mail/sieve-multibox.age;
    mode = "0400";
    owner = "stalwart-mail";
  };
}
