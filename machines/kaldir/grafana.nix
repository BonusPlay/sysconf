{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "graf.bonus.p4";
      rootUrl = "https://graf.bonus.p4/";
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
            url = "https://prom.bonus.p4";
          }
          {
            type = "loki";
            name = "loki";
            url = "https://loki.bonus.p4";
          }
        ];
      };
    };
  };
}
