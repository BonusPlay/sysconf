let
  port = 13100;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  virtualisation.oci-containers.containers.ghidra = {
    image = "blacktop/ghidra:10.3.3-alpine";
    ports = [ "${toString port}:${toString port}" ];
    volumes = [ "/var/lib/ghidra:/repos" ];
    cmd = [ "server" ];
  };
}
