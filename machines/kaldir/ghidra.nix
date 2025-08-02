{ pkgs, ... }:
let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
in
{
  networking.firewall.allowedTCPPorts = ports;
  virtualisation.oci-containers.containers.ghidra = {
    # 11.2.1-alpine ARM!!!
    image = "blacktop/ghidra@sha256:4a00f0a8447536800a68df6fbe2984b721617ad0bfa79c14a0347f8624b98913";
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
