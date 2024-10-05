{ buildGoModule
, config
, fetchFromGitHub
, lib
, nixosTests
, olm
}:

buildGoModule rec {
  pname = "mautrix-meta";
  version = "0.4.0+03.10.2024";

  subPackages = [ "cmd/mautrix-meta" ];

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "meta";
    rev = "321856b9a44242479f54a90a8facec10f115bdbe";
    hash = "sha256-bhkEUjjFsqwj7ZyEO/GpOh+zZ86eGhNMNTf6RErj47Q=";
  };

  buildInputs = [ olm ];

  vendorHash = "sha256-TBtCEGLxMWb1aE+6VlAglRIu9sjfJZWWHlyVC6XscTg=";

  passthru = {
    tests = {
      inherit (nixosTests)
        mautrix-meta-postgres
        mautrix-meta-sqlite
        ;
    };
  };

  meta = {
    homepage = "https://github.com/mautrix/meta";
    description = "Matrix <-> Facebook and Mautrix <-> Instagram hybrid puppeting/relaybot bridge";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ rutherther ];
    mainProgram = "mautrix-meta";
  };
}
