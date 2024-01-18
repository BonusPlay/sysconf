let
  port = 8883;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  containers.mosquitto = {
    autoStart = true;

    config = { config, pkgs, ... }: {
      services.mosquitto = {
        enable = true;
        listeners = [{
          port = port;
          users = {
            "esp32" = {
              acl = [ "readwrite sensors/esp32/#" ];
              hashedPassword = "$7$101$/JRnReEzuZpPuDIO$H9tGTGSv8y6+l8UJsHuYjlJxxeDqfzxM2MeXBavoYigJ57UASmwnpY8s88RaSBBGyenZy8BGsyRtdsFXGICayA==";
            };
            "influx" = {
              acl = [ "read sensors/#" ];
              hashedPassword = "$7$101$xYbNIGLUm0/j7aN/$zjfObOh7NqO1LRQET1dNxj2F1ft20W5beb7cpT35Q75MP1ObKgizlQ1yJITBFNN40qQGx8z4hD7jOblwWK8k6g==";
            };
            "bonus" = {
              acl = [ "readwrite #" ];
              hashedPassword = "$7$101$ZC+JXpJe8n4mCjDz$rYZ+t/zy7Zc03qBNGoP+q02c+DqwXJXHEzKNP6nuMt9DmFY9UE+zCGb3nkHxxy4la54xVe4/9HMTTZLVY1ZbPA==";
            };
          };
        }];
      };

      system.stateVersion = "23.05";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
    };
  };
}
