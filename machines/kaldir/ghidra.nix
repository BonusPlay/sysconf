{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
in
{
  networking.firewall.allowedTCPPorts = ports;

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.ghidra = {
    # 11.0.1-alpine
    image = "blacktop/ghidra@sha256:f93de31b54d6ba98fb31c247ce534a342ab587db2340943c4ad899d808469a46";
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
