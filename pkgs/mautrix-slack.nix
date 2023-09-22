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
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "slack";
    rev = "466ff2417b33d9caa23d0c9a4d7a692f33adf83b";
    sha256 = "iG9pjqB82HupA1q09flIa8/TEjCqzH84VxWlKeM+ltk=";
  };

  vendorSha256 = "Adfz6mHYa22OqEZZHrvst31XdZFo7LuxQI20whq3Zes=";

  ldflags = [ "-s" "-w" ];

  buildInputs = [ olm ];

  doCheck = false;

  #passthru = {
  #  updateScript = nix-update-script { };
  #  tests.version = testers.testVersion {
  #    package = mautrix-slack;
  #  };
  #};

  meta = with lib; {
    description = "A Matrix-Slack puppeting bridge";
    homepage = "https://github.com/mautrix/slack";
    #changelog = "https://github.com/mautrix/slack/blob/${src.rev}/CHANGELOG.md";
    license = licenses.agpl3Only;
    #maintainers = with maintainers; [ MoritzBoehme ];
  };
}
