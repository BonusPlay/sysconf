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
    ./beszel-agent.nix
    ./nginx.nix
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

    boot = {
      kernelParams = [ "console=ttyS0,115200n8" ];
      loader.grub.extraConfig = "
        serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
        terminal_input serial
        terminal_output serial
      ";
    };
  };
}
