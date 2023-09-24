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
    image = "blacktop/ghidra@sha256:a8d1f1095c3519890f093a844cf81f660a72518392511cdd72fd6faef322ff1e";
    ports = map mkPair (map toString ports);
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
    environment = {
      GHIDRA_IP = "$(${ipcmd})";
      GHIDRA_USERS = "bonus";
    };
  };
}
