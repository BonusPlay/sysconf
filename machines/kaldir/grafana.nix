{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "graf.mlwr.dev";
      root_url = "https://graf.mlwr.dev/";
      http_addr = "127.0.0.1";
      http_port = 4060;
    };
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            type = "prometheus";
            name = "prometheus";
            url = "https://prom.mlwr.dev";
          }
          {
            type = "loki";
            name = "loki";
            url = "https://loki.mlwr.dev";
          }
        ];
      };
    };
  };
}
