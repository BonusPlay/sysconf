let
  port = 1883;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = port;
        users = {
          "bonus" = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$ZC+JXpJe8n4mCjDz$rYZ+t/zy7Zc03qBNGoP+q02c+DqwXJXHEzKNP6nuMt9DmFY9UE+zCGb3nkHxxy4la54xVe4/9HMTTZLVY1ZbPA==";
          };
          "ha" = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$xYbNIGLUm0/j7aN/$zjfObOh7NqO1LRQET1dNxj2F1ft20W5beb7cpT35Q75MP1ObKgizlQ1yJITBFNN40qQGx8z4hD7jOblwWK8k6g==";
          };
          "tasmota" = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$/JRnReEzuZpPuDIO$H9tGTGSv8y6+l8UJsHuYjlJxxeDqfzxM2MeXBavoYigJ57UASmwnpY8s88RaSBBGyenZy8BGsyRtdsFXGICayA==";
          };
          "frigate" = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$peTcw8zQj7QuAJZU$a60daOKaybZpYihEvuZfmkez+5tan7R13/8i+QB+9M+SM+hxsxaa1YcOTurTxtBLELRZd8eX6QROVuXbU4hheA==";
          };
        };
      }
    ];
  };
}
