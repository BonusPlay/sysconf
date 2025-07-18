{ config, ... }:
{
  services.esphome = {
    enable = true;
    usePing = true;
    address = "0.0.0.0";
    openFirewall = true;
  };

  networking.firewall.allowedUDPPorts = [ 5353 ];
}
