{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, pyuptimekuma
}:

buildHomeAssistantComponent rec {
  owner = "bonus";
  domain = "uptime_kuma";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "meichthys";
    repo = "uptime_kuma";
    rev = "v${version}";
    hash = "sha256-6NrRuBjpulT66pVUfW9ujULL5HSzfgyic1pKEBRupNA=";
  };

  propagatedBuildInputs = [
    pyuptimekuma
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
