{ lib
, buildGoModule
, fetchFromGitHub
, olm
, nix-update-script
, testers
#, mautrix-slack
}:

buildGoModule rec {
  pname = "mautrix-slack";
  version = "unstable-25-09-2023";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "slack";
    rev = "4530ff397d08d93b673cd71da4c2a75d969ca0df";
    hash = "sha256-zq5Qzdw6MhBJDMmi2SWHTEyOghpfLiQOEf0e2Fn+ww8=";
  };

  vendorHash = "sha256-Adfz6mHYa22OqEZZHrvst31XdZFo7LuxQI20whq3Zes=";

  ldflags = [ "-s" "-w" ];

  buildInputs = [ olm ];

  doCheck = false;

  meta = with lib; {
    description = "A Matrix-Slack puppeting bridge";
    homepage = "https://github.com/mautrix/slack";
    #changelog = "https://github.com/mautrix/slack/blob/${src.rev}/CHANGELOG.md";
    license = licenses.agpl3Only;
    #maintainers = with maintainers; [ MoritzBoehme ];
  };
}
