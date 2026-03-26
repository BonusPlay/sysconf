{ nixpkgs-unstable }:
final: prev: {
  pkgs-unstable = import nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = prev.config;
  };
}
