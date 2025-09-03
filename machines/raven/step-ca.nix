{ config, lib, pkgs, ... }:
let
  pkcs11-pass = config.age.secrets.pkcs11-pass.path;
  tier-crt = tier: config.age.secrets."${tier}".path;
  nitrokeys = {
    tier0 = "000f661969d0";
    tier1 = "000f8aa0a312";
    tier2 = "000f57fba9fb";
  };
  nitro-serial = tier: builtins.getAttr tier nitrokeys;
  root-crt = config.age.secrets.root.path;
  mkStepCfg = port: tier: {
    address = "0.0.0.0";
    port = port;
    openFirewall = true;
    # dummy, we don't really have pass but nixos requires it
    intermediatePasswordFile = "/dev/null";
    settings = {
      root = root-crt;
      federatedRoots = null;
      crt = tier-crt tier;
      key = "pkcs11:id=%03;object=Authentication%20key;serial=${nitro-serial tier};token=OpenPGP%20card%20%28User%20PIN%29";
      kms = {
        type = "pkcs11";
        uri = "pkcs11:module-path=${pkgs.opensc}/lib/opensc-pkcs11.so;serial=${nitro-serial tier}?pin-source=${pkcs11-pass}";
      };
      crl.enabled = true;
      dnsNames = [ "${tier}.pki.xakep.lan" ];
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "87600h";
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
        dataSource = "/var/lib/step-ca/${tier}/db";
        valueDir = "/var/lib/step-ca/${tier}/valuedb";
      };
    };
  };
in
{
  custom.step-ca = {
    enable = true;
    instances = {
      tier0 = mkStepCfg 8440 "tier0";
      tier1 = mkStepCfg 8441 "tier1";
      tier2 = mkStepCfg 8442 "tier2";
    };
  };

  services.pcscd.enable = true;

  age.secrets = {
    pkcs11-pass = {
      file = ../../secrets/ca/pkcs11-pass.age;
      mode = "0444";
    };
    root = {
      file = ../../secrets/ca/root-crt.age;
      mode = "0444";
    };
    tier0 = {
      file = ../../secrets/ca/tier0-crt.age;
      mode = "0444";
    };
    tier1 = {
      file = ../../secrets/ca/tier1-crt.age;
      mode = "0444";
    };
    tier2 = {
      file = ../../secrets/ca/tier2-crt.age;
      mode = "0444";
    };
  };
}
