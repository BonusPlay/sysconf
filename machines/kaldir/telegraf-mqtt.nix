{ config, lib, ... }:
{
  age.secrets.telegraf-mqtt = {
    file = ../../secrets/telegraf-mqtt-env.age;
    mode = "0400";
    owner = "telegraf";
  };

  services.telegraf = {
    enable = true;
    environmentFiles = [ config.age.secrets.telegraf-mqtt.path ];
    extraConfig = {
      inputs = {
        mqtt_consumer = {
          servers = [ "tcp://mqtt.bonusplay.pl:8883" ];
          topics = [ "sensors/#" ];
          username = "influx";
          password = "$MQTT_PASSWORD";
          data_format = "value";
          data_type = "float";
        };
      };
      outputs = {
        influxdb_v2 = {
          urls = [ "https://influx.mlwr.dev" ];
          token = "$INFLUX_TOKEN";
          organization = "khala";
          bucket = "sensors";
          content_encoding = "gzip";
        };
      };
    };
  };
}
