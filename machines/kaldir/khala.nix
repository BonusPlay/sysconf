{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 4040;
    serverUrl = "https://khala.bonusplay.pl";
    aclPolicyFile = "/etc/headscale/acl.json";
    settings = {
      ip_prefixes = "198.18.66.0/24";
      tls_client_auth_mode = "disabled";
    };
  };

  services.tailscale = {
    enable = true;
    interfaceName = "p4net-khala";
  };

  environment.etc."headscale/acl.json" = let
    aclConfig = {
      groups = {
        "group:bonus" = [ "bonus" ];
        "group:servers" = [ "kaldir" ];
      };
      tagOwners = {
        "tag:servers" = [ "group:servers" ];
      };
      acls = [
        {
          action = "accept";
          src = [ "bonus" ];
          dst = [ "bonus:*" ];
        }
        {
          action = "accept";
          src = [ "group:bonus" ];
          dst = [ "tag:servers:*" ];
        }
      ];
    };
  in {
    user = "headscale";
    mode = "0660";
    text = builtins.toJSON aclConfig;
  };
}
