let
  hostIP = "192.168.100.1";
  containerIP = "192.168.100.10";
  port = 8883;
in
{
  containers.mosquitto = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.1";
    localAddress = "192.168.100.10";

    config = { config, pkgs, ... }: {

      services.mosquitto = {
        enable = true;
        listeners = [{
          port = port;
          users = {
            "uganda-door" = {
              acl = [ "readwrite uganda/#" ];
              hashedPassword = "$7$101$xlt6Ba/4UwrqfweJ$QjNP5Vc49qFqPC/90QDfoKS+n9gRunzkiSYSANQ3jb1JrLoP6i5Mc5d8JTctnCxLvRZYdkDm8h0ehXCi47YcmA==";
            };
            "uganda-chat" = {
              acl = [ "readwrite uganda/#" ];
              hashedPassword = "$7$101$JkamWLMhVyWJsd3L$PI2Sht1k4815G3VMvjfyXMkgl1X7o1ShN53ylXEhsbjJh9xfh4AgY0Zoy8rwY0ntGI/tTFep7VT7ls/LXdOc3g==";
            };
          };
        }];
      };

      system.stateVersion = "22.11";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ port ];
      };
      environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
    };
  };
}
