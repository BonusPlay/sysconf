{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.server;
in
{
  imports = [
    ./base.nix
    ./caddy.nix
    ./monitoring.nix
    ./warp-net.nix
  ];

  options.custom.server = {
    enable = mkEnableOption "base configuration of Bonus's servers";
    vm = mkOption {
      type = types.bool;
      description = "is this a VM (enable qemu agent)";
    };
  };

  config = mkIf cfg.enable {
    nix.gc.automatic = true;
    users.users.bonus = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    services.qemuGuest.enable = cfg.vm;
    services.openssh.enable = true;
    security.sudo.wheelNeedsPassword = false;

    # for now we do this, later we can add separate account
    nix.settings.trusted-users = [ "bonus" ];
  };
}
