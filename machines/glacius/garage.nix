{ config, pkgs, ... }:
let
  rpc_port = 3901;
  s3_port = 3900;
in
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1_2_0;
    environmentFile = config.age.secrets.garage-env.path;
    settings = {
      replication_factor = 1;
      consistency_mode = "consistent";
      rpc_bind_addr = "0.0.0.0:${toString rpc_port}";
      rpc_public_addr = "0.0.0.0:${toString rpc_port}";
      s3_api = {
        api_bind_addr = "0.0.0.0:${toString s3_port}";
        s3_region = "garage";
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

  networking.firewall.allowedTCPPorts = [ s3_port rpc_port ];
}
