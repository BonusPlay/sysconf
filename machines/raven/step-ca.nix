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
      authority.provisioners = [
        {
          type = "ACME";
          name = "warp";
          forceCN = true;
          challenges = ["http-01" "tls-alpn-01"];
          disableSmallstepExtensions = true;
          options.x509.templateFile = "/etc/smallstep/leaf.tpl";
        }
      ];
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
