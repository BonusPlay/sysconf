{ lib, config, ... }:
with lib;
let
  cfg = config.custom.warp-net;
in
{
  options.custom.warp-net = {
    enable = mkEnableOption "enable warp-net via tailscale";
    exitNode = mkOption {
      type = types.bool;
      default = false;
      description = "should this be an exit node";
    };
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "additional flags";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      interfaceName = "warp-net";
      useRoutingFeatures = if cfg.exitNode then "both" else "client";
      extraUpFlags = [ "--accept-routes" ] ++ cfg.extraFlags;
    };

    systemd.network.wait-online.ignoredInterfaces = [ "warp-net" ];
  };
}
