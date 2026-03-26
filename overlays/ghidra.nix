final: prev: {
  ghidra = final.pkgs-unstable.ghidra;
  ghidra-extensions = {
    arcompact = final.pkgs-unstable.callPackage ../pkgs/ghidra-arcompact.nix {};
    binexport = final.pkgs-unstable.callPackage ../pkgs/ghidra-binexport {};
    ctrlp = final.pkgs-unstable.callPackage ../pkgs/ghidra-ctrlp.nix {};
    ghidralib = final.pkgs-unstable.callPackage ../pkgs/ghidra-lib.nix {};
    wasm = final.pkgs-unstable.callPackage ../pkgs/ghidra-wasm.nix {};
  } // final.pkgs-unstable.ghidra-extensions;
}
