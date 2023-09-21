let
  ports = [ 13100 13101 13102 ];
  mkPair = port: "${port}:${port}";
in
{
  networking.firewall.allowedTCPPorts = ports;

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.ghidra = {
    image = "blacktop/ghidra:10.3.3-alpine";
    ports = map mkPair (map toString ports);
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
    environment = {
      GHIDRA_IP = "0.0.0.0";
      GHIDRA_USERS = "bonus";
    };
  };
}
