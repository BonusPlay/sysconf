{ config, pkgs, ... }:
let
  s3_port = 3900;
  ts_ip = "100.103.141.53";
in
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1_0_1;
    environmentFile = config.age.secrets.garage-env.path;
    settings = {
      replication_factor = 1;
      consistency_mode = "consistent";
      rpc_bind_addr = "${ts_ip}:3901";
      rpc_public_addr = "${ts_ip}:3901";
      s3_api = {
        api_bind_addr = "127.0.0.1:${toString s3_port}";
        s3_region = "garage";
        root_domain = ".s3.warp.lan";
      };
      #s3_web.bind_addr = null;
      #admin.api_bind_addr = null;
    };
  };

  # fixup user/group
  systemd.services.garage.serviceConfig = {
    DynamicUser = false;
    User = "garage";
    Group = "garage";
  };
  users.groups.garage = {};
  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };

  age.secrets.garage-env = {
    file = ../../secrets/garage-env.age;
    mode = "0400";
    owner = "garage";
  };

  custom.caddy.entries = [
    {
      entrypoints = [ ts_ip ];
      domain = "s3.warp.lan";
      port = s3_port;
    }
  ];
}
