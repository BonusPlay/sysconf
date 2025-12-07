{ nixpkgs-unstable }:
final: prev:
  let
    pkgs = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
  in
  {
    ghidra = pkgs.ghidra;
    ghidra-extensions = {
      arcompact = pkgs.callPackage ../pkgs/ghidra-arcompact.nix {};
      binexport = pkgs.callPackage ../pkgs/ghidra-binexport {};
      ctrlp = pkgs.callPackage ../pkgs/ghidra-ctrlp.nix {};
      ghidralib = pkgs.callPackage ../pkgs/ghidra-lib.nix {};
      wasm = pkgs.callPackage ../pkgs/ghidra-wasm.nix {};
    } // pkgs.ghidra-extensions;
  }
