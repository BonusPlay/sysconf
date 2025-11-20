{ config, ... }:
{
  services.esphome = {
    enable = true;
    usePing = true;
    address = "0.0.0.0";
    openFirewall = true;
  };

  # required for mdns
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
