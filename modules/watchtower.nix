{ lib, config, ... }:
let
  cfg = config.custom.watchtower;
in
{
  options.custom.watchtower = {
    enable = lib.mkEnableOption "deploy watchtower";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.custom.podman.enable;
        message = "watchtower assumes podman module is enabled";
      }
    ];

    virtualisation.oci-containers.containers.watchtower = {
      image = "docker.io/containrrr/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      cmd = [ "--interval" "30" ];
    };
  };
}
