{ config, lib, ... }:
let
  telegraf-mqtt-env = "/run/telegraf-mqtt-env";
in
{
  age.secrets.telegraf-mqtt-env = {
    file = ../../secrets/telegraf-mqtt-env.age;
    mode = "0400";
    owner = "telegraf";
  };

  containers.telegraf-mqtt = {
    autoStart = true;
    bindMounts.telegraf-mqtt-env = {
      hostPath = config.age.secrets.telegraf-mqtt-env.path;
      mountPoint = telegraf-mqtt-env;
      isReadOnly = true;
    };
    # required for memguard (dependency of telegraf)
    additionalCapabilities = [ "CAP_IPC_LOCK" ];

    config = { config, ... }: {
      services.telegraf = {
        enable = true;
        environmentFiles = [ telegraf-mqtt-env ];
        extraConfig = {
          inputs = {
            mqtt_consumer = {
              servers = [ "tcp://mqtt.bonusplay.pl:8883" ];
              topics = [ "sensors/#" ];
              username = "influx";
              password = "$MQTT_PASSWORD";

              topic_parsing = {
                topic = "sensors/+";
                measurement = "_/measurement";
                tags = "sensor_id/_";
              };
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
      
      system.stateVersion = "23.11";
    };
  };
}
