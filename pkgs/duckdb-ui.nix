# src: https://github.com/NixOS/nixpkgs/issues/370630#issuecomment-2972749016
{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, openssl
, python3
, git
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "duckdb-ui";
  version = "0-unstable-2025-12-10";

  src = fetchFromGitHub {
    owner = "duckdb";
    repo = "duckdb-ui";
    rev = "a706ce445f64081b28061b00e502f92090184a75";
    #hash = "sha256-CNZor5BOzWa9Cyal2IVu8MRf5DDwQGyGD6nQZETY0lc=";
    hash = "sha256-w4/ntVrQtwI9+ysF+zqbVxhBUE5d42dg994LlusFPS0=";

    # Build currently requires git
    leaveDotGit = true;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
    git
  ];
  buildInputs = [ openssl ];

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;
  doInstallCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/extension/ui
    cp build/release/extension/ui/*.duckdb_extension $out/extension/ui/
    runHook postInstall
  '';
})
