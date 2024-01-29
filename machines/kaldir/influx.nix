{ config, lib, ... }:
let
  port = lib.toInt (lib.strings.removePrefix "${config.containers.influx.localAddress}:" config.containers.influx.config.services.influxdb2.settings.http-bind-address);
in
{
  custom.traefik.entries = [
    {
      name = "influx";
      domain = "influx.mlwr.dev";
      target = config.containers.influx.localAddress;
      port = port;
      entrypoints = [ "warps" ];
    }
  ];

  networking.nat = {
    internalInterfaces = [ "ve-influx" ];
  };

  containers.influx = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.28.2.1";
    localAddress = "172.28.2.2";

    config = { config, ... }: {
      services.influxdb2 = {
        enable = true;
        settings = {
          reporting-disabled = true;
          http-bind-address = "172.28.2.2:8086";
        };
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };

      system.stateVersion = "23.05";
    };
  };
}
