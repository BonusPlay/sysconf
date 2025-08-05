{ config, lib, pkgs, ... }:
let
   pkcs11-pass = config.age.secrets.pkcs11-pass.path;
   tier-crt = tier: config.age.secrets."${tier}".path;
   nitrokeys = {
     tier0 = "000f57fba9fb";
     tier1 = "000f661969d0";
     tier2 = "000f8aa0a312";
   };
   root-crt = config.age.secrets.root.path;
   mkStepContainer = port: tier: {
     autoStart = true;
     bindMounts = {
       "${pkcs11-pass}".isReadOnly = true;
       "${tier-crt tier}".isReadOnly = true;
       "${root-crt}".isReadOnly = true;
     };
     allowedDevices = [
       { node = "/dev/bus/usb/009/002"; modifier = "rwm"; }
     ];
     config = { config, pkgs, ... }: {
       services.pcscd.enable = true;
       system.stateVersion = "25.05";
       services.step-ca = {
         enable = true;
         address = "0.0.0.0";
         port = port;
         openFirewall = true;
         # dummy, we don't really have pass but nixos requires it
         intermediatePasswordFile = "/dev/null";
         settings = {
           root = root-crt;
           federatedRoots = null;
           crt = tier-crt tier;
           key = "pkcs11:id=%03;object=Authentication%20key;serial=${builtins.getAttr tier nitrokeys};token=OpenPGP%20card%20%28User%20PIN%29";
           kms = {
             type = "pkcs11";
             uri = "pkcs11:module-path=${pkgs.opensc}/lib/opensc-pkcs11.so;slot-id=0?pin-source=${pkcs11-pass}";
           };
           crl.enabled = true;
           dnsNames = [ "pki.xakep.lan" ];
           authority = {
             claims = {
               minTLSCertDuration = "5m";
               maxTLSCertDuration = "8760h";
               defaultTLSCertDuration = "48h";
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
in
{
  containers = {
    step-tier0 = mkStepContainer 443 "tier0";
    step-tier1 = mkStepContainer 444 "tier1";
    step-tier2 = mkStepContainer 445 "tier2";
  };

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
