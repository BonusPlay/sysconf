{ nixpkgs-unstable }:
final: prev: {
  ghidra = nixpkgs-unstable.legacyPackages.${prev.system}.ghidra;
  ghidra-extensions = {
    arcompact = prev.callPackage ../pkgs/ghidra-arcompact.nix {};
    ctrlp = prev.callPackage ../pkgs/ghidra-ctrlp.nix {};
    wasm = prev.callPackage ../pkgs/ghidra-wasm.nix {};
  } // nixpkgs-unstable.legacyPackages.${prev.system}.ghidra-extensions;
}
