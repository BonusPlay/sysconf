{ nixpkgs-unstable }:
final: prev: {
  beszel = nixpkgs-unstable.legacyPackages.${prev.system}.beszel;
}
