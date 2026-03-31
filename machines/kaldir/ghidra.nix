{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
in
{
  networking.firewall.allowedTCPPorts = ports;
  virtualisation.oci-containers.containers.ghidra = {
    # 12.0.4-alpine
    image = "blacktop/ghidra@sha256:a5f386ce5daa32a1a601753555fdd846e75b99d8b68b72d449ac615a4eb5ce44";
    ports = map mkPair (map toString ports);
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
    environment = {
      GHIDRA_IP = "ghidra.bonusplay.pl";
      GHIDRA_USERS = "bonus";
    };
  };
}
