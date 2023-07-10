{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.server;
in
{
  options.custom.server = {
    enable = mkEnableOption "base configuration of Bonus's servers";
  };

  config = mkIf cfg.enable {
    users.users.bonus = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    services.qemuGuest.enable = true;
    services.openssh.enable = true;
    security.sudo.wheelNeedsPassword = false;
  };
}
