{
  services.headscale = {
    enable = true;
    settings = builtins.toJSON {
      db_path = "/var/lib/headscale/db.sqlite";
      db_type = "sqlite3";
      derp = {
        auto_update_enable = true;
        paths = [];
        update_frequency = "24h";
        urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
      };
      disable_check_updates = true;
      dns_config = {
        base_domain = "";
        domains = [];
        magic_dns = true;
        nameservers = [ "1.1.1.1" ];
      };
      ephemeral_node_inactivity_timeout = "30m";
      listen_addr = "0.0.0.0:8080";
      log_level = "info";
      oidc = {
        client_id = "";
        domain_map = {};
        issuer = "";
      };
      private_key_path = "/var/lib/headscale/private.key";
      server_url = "https://kaldir.bonusplay.pl";
      tls_letsencrypt_cache_dir = "/var/lib/headscale/.cache";
      tls_letsencrypt_challenge_type = "HTTP-01";
      tls_letsencrypt_hostname = "*.bonusplay.pl";
      tls_letsencrypt_listen = ":8080";
      unix_socket = "/run/headscale/headscale.sock";
    };
  };
}
