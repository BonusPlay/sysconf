{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
  ipcmd = "${pkgs.dig}/bin/dig +short ghidra.bonusplay.pl | tail -1 | tr -d '\n'";
in
{
  networking.firewall.allowedTCPPorts = ports;

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.ghidra = {
    # 10.3.3-alpine
    image = "blacktop/ghidra@sha256:464929a50b74180213872dd740be3c44cdfeb9bcd948a9a242e5c4f8805d3cc3";
    ports = map mkPair (map toString ports);
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
    environment = {
      GHIDRA_IP = "$(${ipcmd})";
      GHIDRA_USERS = "bonus";
    };
  };
}
