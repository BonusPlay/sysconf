{ buildGoModule
, config
, fetchFromGitHub
, lib
, nixosTests
, olm
}:

buildGoModule rec {
  pname = "mautrix-meta";
  version = "0.3.1+unstable";

  subPackages = [ "." ];

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "meta";
    rev = "df9251e14c72fdbffb15632a704904041198da07";
    hash = "sha256-+x3MdieEjT/maoYXt9oaDgPSBAUd6d/nFf0vzQ5f0Qo=";
  };

  buildInputs = [ olm ];

  vendorHash = "sha256-uwprj4G7HI87ZGr+6Bqkp77nzW6kgV3S5j4NGjbtOwQ=";

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
