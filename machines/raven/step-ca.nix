{ config, lib, ... }:
{
  age.secrets = {
    intermediate-crt = {
      file = ../../secrets/ca/intermediate-crt.age;
      owner = "step-ca";
      mode = "0400";
    };
    intermediate-key = {
      file = ../../secrets/ca/intermediate-key.age;
      owner = "step-ca";
      mode = "0400";
    };
    intermediate-key-pass = {
      file = ../../secrets/ca/password-file.age;
      owner = "step-ca";
      mode = "0400";
    };
  };

  services.step-ca = {
    enable = true;
    address = "100.105.144.36";
    port = 443;
    openFirewall = true;
    intermediatePasswordFile = config.age.secrets.intermediate-key-pass.path;
    settings = {
      root = "/etc/ssl/certs/warp-net.crt";
      federatedRoots = null;
      crt = config.age.secrets.intermediate-crt.path;
      key = config.age.secrets.intermediate-key.path;
      dnsNames = [ "pki.warp.lan" ];
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "8760h";
          defaultTLSCertDuration = "48h";
        };
        provisioners = [
          {
            type = "ACME";
            name = "warp";
            forceCN = true;
            challenges = ["http-01" "tls-alpn-01"];
            disableSmallstepExtensions = true;
            options.x509.templateFile = "/etc/smallstep/leaf.tpl";
          }
          {
            type = "JWK";
            name = "jwk";
            key = {
              use = "sig";
              kty = "OKP";
              kid = "y2ozd5b1_1FTAQFaXJy50bscW3RSx3MYDokIbzuKbcU";
              crv = "Ed25519";
              alg = "EdDSA";
              x = "Buy89wJj9eWooDe4bOfveyEaMhTbgEUdp78mt8tWAJQ";
            };
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzUxMitBMjU2S1ciLCJlbmMiOiJBMjU2R0NNIiwicDJjIjo2MDAwMDAsInAycyI6IlBqMjJydjNXZkJvNk1PZlU0NzZXUncifQ.WT20cO4XTQThjnw9U62hMKlXCQqq3-v9dID_HqrpQM-xcHT3K1t-Vg.o7O_cI8--ZouXLzk.yCG8fd4EqR_hQ7gz0y9NtEKI-0LIi8HDBMSTFlVqQJ5rbwT2oowH4FfONQFn0dtBPpgqm-LVB8NxyumzYlxkur4mL8pxIYOv70RDCeyV4IxSy--pw-xOaiidWr1Tpzgbm2YwgQXZuYMMHMvb--N8gs2oMCts2PmTrkzemuH6TuJBoThP4jsR9EORGRS1k98IMPIDz0v9jeQpJ_0K3o7TBm_eH95q4URsriix24qMLKWgzIUCCuqXmkHM5i_U6O3bt9u0JUVjTQF7RtCI7ayh.UME4ogom43Ipk4ZH4tEQdg";
          }
        ];
      };
      db = {
        type = "badger";
        dataSource = "/var/lib/step-ca/db";
        valueDir = "/var/lib/step-ca/valuedb";
      };
    };
  };

  environment.etc."smallstep/leaf.tpl".text = ''
    {
      "subject": {
        "organization": "warp-net",
        "commonName": {{ .Subject.CommonName | toJson }}
      },
      "sans": {{ toJson .SANs }},
    {{- if typeIs "*rsa.PublicKey" .Insecure.CR.PublicKey }}
      "keyUsage": ["keyEncipherment", "digitalSignature"],
    {{- else }}
      "keyUsage": ["digitalSignature"],
    {{- end }}
      "extKeyUsage": ["serverAuth", "clientAuth"]
    }
  '';
}
