# https://github.com/NixOS/nixpkgs/pull/388655/files
# TODO: remove hack in deplyoment (settings)
final: prev: let
  src = prev.fetchFromGitHub {
    owner = "sysadminsmedia";
    repo = "homebox";
    rev = "v0.18.0";
    hash = "sha256-6iNlx0lBVU/awUZHqRYFKe84D86EJNFF7Nm1XChs75w=";
  };
in {
  homebox = prev.homebox.overrideAttrs(old: {
    inherit src;
    version = "0.18.0";
    vendorHash = "sha256-TxuydZjlT8Y4BB77Z8Tyn8j0SPTU2O12TNm9PQGZXTw=";
    pnpmDeps = prev.pnpm_9.fetchDeps {
      pname = "homebox";
      version = "0.18.0";
      src = "${src}/frontend";
      hash = "sha256-NjuthspxojlrCofAj4Egre8s5PG7vvPJW5mzrvAW4TQ=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -r $GOPATH/bin/api $out/bin/
      runHook postInstall
    '';
  });
}
