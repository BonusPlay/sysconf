{
  services.influxdb2 = {
    enable = true;
    settings = {
      reporting-disabled = true;
      http-bind-address: "127.0.0.1:8086"
    };
  };
}
