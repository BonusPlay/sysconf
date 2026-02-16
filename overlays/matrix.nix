{ nixpkgs-unstable }:
final: prev:
  let
    pkgs = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
  in
  {
    mautrix-meta = pkgs.mautrix-meta;
    mautrix-slack = pkgs.mautrix-slack;
    mautrix-telegram = pkgs.mautrix-telegram;
  }
