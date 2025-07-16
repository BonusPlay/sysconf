{ config, lib, pkgs, ... }:
{
  services.step-ca = {
    enable = true;
    address = "0.0.0.0";
    port = 443;
    openFirewall = true;
    # dummy, we don't really have pass but nixos requires it
    intermediatePasswordFile = "/dev/null";
    settings = {
      root = config.age.secrets.root-crt.path;
      federatedRoots = null;
      crt = config.age.secrets.intermediate-crt.path;
      key = "pkcs11:id=%03;object=Authentication%20key;token=OpenPGP%20card%20%28User%20PIN%29";
      kms = {
        type = "pkcs11";
        uri = "pkcs11:module-path=${pkgs.opensc}/lib/opensc-pkcs11.so;slot-id=0?pin-source=${config.age.secrets.pkcs11-pass.path}";
      };
      crl.enabled = true;
      dnsNames = [ "pki.xakep.lan" ];
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "8760h";
          defaultTLSCertDuration = "48h";
        };
        provisioners = [
          {
            type = "ACME";
            name = "acme";
            forceCN = true;
            challenges = ["http-01" "tls-alpn-01"];
            disableSmallstepExtensions = true;
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

  services.pcscd.enable = true;

  age.secrets = {
    root-crt = {
      file = ../../secrets/ca/root-crt.age;
      owner = "step-ca";
      mode = "0400";
    };
    intermediate-crt = {
      file = ../../secrets/ca/intermediate-crt.age;
      owner = "step-ca";
      mode = "0400";
    };
    pkcs11-pass = {
      file = ../../secrets/ca/pkcs11-pass.age;
      owner = "step-ca";
      mode = "0400";
    };
  };
}
