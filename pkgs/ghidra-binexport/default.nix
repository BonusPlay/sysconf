{ lib
, fetchFromGitHub
, ghidra
, gradle
}:
let
self = ghidra.buildGhidraExtension {
  pname = "ghidra-binexport";
  version = "unstable-29-12-2024";

  src = fetchFromGitHub {
    owner = "google";
    repo = "binexport";
    rev = "23619ba62d88b3b93615d28fe3033489d12b38ac";
    hash = "sha256-hXb/g5BuEawUjJZPRwjKFkqZTDXDGzHSRJLYqdenMlU=";
  };

  sourceRoot = "source/java";

  mitmCache = gradle.fetchDeps {
    pkg = self;
    data = ./deps.json;
  };

  meta = with lib; {
    description = "";
    homepage = "";
    downloadPage = "";
    license = licenses.gpl3;
  };
};
in
self
