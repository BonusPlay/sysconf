{ lib, config, pkgs, ... }:
let
  cfg = config.custom.monitoring;
  port = 45876;
in
{
  options.custom.monitoring = {
    enable = lib.mkEnableOption "monitoring";
  };

  config = lib.mkIf cfg.enable {
    custom.beszel-agent = {
      enable = true;
      environmentFile = config.age.secrets.beszel-env.path;
      environment.PORT = toString port;
    };

    age.secrets.beszel-env = {
      file = ../secrets/beszel-env.age;
      mode = "0400";
      owner = config.custom.beszel-agent.user;
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
