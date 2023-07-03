{
  services.tailscale = {
    enable = true;
    interfaceName = "warp-net";
    useRoutingFeatures = "client";
  };
}
