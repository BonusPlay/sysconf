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
              acl = [ "readwrite esp32/#" ];
              hashedPassword = "$7$101$/JRnReEzuZpPuDIO$H9tGTGSv8y6+l8UJsHuYjlJxxeDqfzxM2MeXBavoYigJ57UASmwnpY8s88RaSBBGyenZy8BGsyRtdsFXGICayA==";
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
