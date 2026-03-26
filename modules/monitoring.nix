{ lib, config, pkgs, ... }:
let
  cfg = config.custom.monitoring;
in
{
  options.custom.monitoring = {
    enable = lib.mkEnableOption "monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.beszel.agent = {
      enable = true;
      environmentFile = config.age.secrets.beszel-env.path;
      openFirewall = true;
    };

    age.secrets.beszel-env = {
      file = ../secrets/beszel-env.age;
      mode = "0400";
      owner = "beszel-agent";
    };
  };
}
