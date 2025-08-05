{ config, ... }:
{
  services.open-webui = {
    enable = true;
    port = 4020;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "False";
    };
  };

  custom.litellm = {
    enable = true;
    environmentFile = config.age.secrets.litellm-env.path;
    settings = {
      general_settings.master_key = "os.environ/MASTER_KEY";
      model_list = [
        {
          model_name = "Claude 3.5 Sonnet";
          litellm_params = {
            model = "claude-3-5-sonnet-20241022";
            api_key = "os.environ/ANTHROPIC_API_KEY";
          };
        }
      ];
    };
  };

  age.secrets.litellm-env = {
    file = ../../secrets/litellm-env.age;
    mode = "0440";
    group = config.custom.litellm.group;
  };

  custom.caddy.entries = [
    {
      entrypoints = [ "10.0.0.131" ];
      domain = "ai.bonus.re";
      port = config.services.open-webui.port;
    }
  ];
}
