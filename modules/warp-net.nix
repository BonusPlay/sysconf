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
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      interfaceName = "warp-net";
      useRoutingFeatures = if cfg.exitNode then "both" else "client";
    };
  };
}
