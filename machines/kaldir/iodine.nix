{ config, ... }:
{
  services.iodine.server = {
    enable = true;
    ip = "172.16.10.1/24";
    domain = "tunnel.bonus.re";
    passwordFile = config.age.secrets.iodinePass.path;
    extraConfig = "-l 10.0.0.131";
  };

  # we need port 53 for iodine
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  age.secrets.iodinePass = {
    file = ../../secrets/iodine-pass.age;
    group = "iodined";
    mode = "0440";
  };
}
