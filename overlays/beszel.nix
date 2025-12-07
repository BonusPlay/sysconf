{ nixpkgs-unstable }:
final: prev: {
  beszel = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.beszel;
}
