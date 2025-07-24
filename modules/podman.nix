{ lib, config, pkgs, ... }:
let
  cfg = config.custom.podman;
in
{
  options.custom.podman = {
    enable = lib.mkEnableOption "podman";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.compose_warning_logs = false;
      };
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ BonusPlay ];
}
