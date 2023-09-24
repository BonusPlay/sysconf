{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
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
      # TODO: somehow avoid hardcoding IPs (this does need to be a public IP)
      GHIDRA_IP = "130.162.49.48";
      GHIDRA_USERS = "bonus";
    };
  };
}
