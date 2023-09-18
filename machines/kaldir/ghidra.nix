let
  port = 13100;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  virtualisation.oci-containers.containers.ghidra = {
    image = "blacktop/ghidra:10.3.3-alpine";
    ports = [ "${port}:${port}" ];
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
  };
}
