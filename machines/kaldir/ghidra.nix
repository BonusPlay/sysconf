{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
in
{
  networking.firewall.allowedTCPPorts = ports;

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.ghidra = {
    # 11.0.1-alpine ARM!!!
    image = "blacktop/ghidra@sha256:64c777f1db42fb5c842b43d1de7737408bf1061656224d2727161aea1f954cb5";
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
