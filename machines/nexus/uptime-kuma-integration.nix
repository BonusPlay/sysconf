{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, pyuptimekuma-hass
}:
let
  version = "2.3.0";
in
buildHomeAssistantComponent {
  owner = "meichthys";
  domain = "uptime_kuma";
  inherit version;

  src = fetchFromGitHub {
    owner = "meichthys";
    repo = "uptime_kuma";
    rev = "v${version}";
    hash = "sha256-7YSXqYeBaJvQA5lVyb95XbmXE9q8GxTWIIxuQ+HOrts=";
  };

  # when building, tests check if `pyuptimekuma-hass` module imports
  # however, the module is imported by `pyuptimekuma`
  patchPhase = ''
    sed -i 's/pyuptimekuma-hass/pyuptimekuma/' custom_components/uptime_kuma/manifest.json
  '';

  propagatedBuildInputs = [
    pyuptimekuma-hass
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Reads data from the uptime kuma into Home Assistant";
    homepage = "https://github.com/meichthys/uptime_kuma";
    changelog = "https://github.com/meichthys/uptime_kuma/releases/tag/v${version}";
    #maintainers = with maintainers; [ presto8 ];
    #license = licenses.mit;
  };
}
