{ config, ... }:
let
  openai-models = [
    { name = "GPT-5"; api-name = "gpt-5"; }
    { name = "GPT-4o"; api-name = "gpt-4o"; }
    { name = "GPT-image"; api-name = "gpt-image-1"; }
  ];
  anthropic-models = [
    { name = "Claude 4.1 Opus"; api-name = "claude-opus-4-1-20250805"; }
    { name = "Claude 4 Sonnet"; api-name = "claude-sonnet-4-20250514"; }
  ];
  mkModelEntry = model: vendor: {
    model_name = model.name;
    litellm_params = {
      model = model.api-name;
      api_key = "os.environ/${vendor}_API_KEY";
    };
  };
  openai-entries = map (model: mkModelEntry model "OPENAI") openai-models;
  anthropic-entries = map (model: mkModelEntry model "ANTHROPIC") anthropic-models;
in
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
      model_list = openai-entries ++ anthropic-entries;
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
