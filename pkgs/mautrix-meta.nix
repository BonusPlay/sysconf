{ lib, buildGoModule, fetchFromGitHub, olm, config, ... }:

buildGoModule rec {
  pname = "mautrix-meta";
  version = "0.3.0";

  subPackages = [ "." ];

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "meta";
    rev = "v${version}";
    hash = "sha256-QyVcy9rqj1n1Nn/+gBufd57LyEaXPyu0KQhAUTgNmBA=";
  };

  buildInputs = [ olm ];

  vendorHash = "sha256-oQSjP1WY0LuxrMtIrvyKhize91wXJxTzWeH0Y3MsEL4=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/mautrix/meta";
    description = "Matrix <-> Facebook and Mautrix <-> Instagram hybrid puppeting/relaybot bridge";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ rutherther ];
    mainProgram = "mautrix-meta";
  };
}
