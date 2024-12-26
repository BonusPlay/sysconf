{ nixpkgs-unstable }:
final: prev:
  let
    pkgs = nixpkgs-unstable.legacyPackages.${prev.system};
  in
  {
    ghidra = pkgs.ghidra;
    ghidra-extensions = {
      arcompact = pkgs.callPackage ../pkgs/ghidra-arcompact.nix {};
      ctrlp = pkgs.callPackage ../pkgs/ghidra-ctrlp.nix {};
      ghidralib = pkgs.callPackage ../pkgs/ghidra-lib.nix {};
      wasm = pkgs.callPackage ../pkgs/ghidra-wasm.nix {};
    } // pkgs.ghidra-extensions;
  }
