{ pkgs, lib,  ... }:
let
  inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;
in
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ rustup clang ]);
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      wholroyd.jinja
      rust-lang.rust-analyzer
      (buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "Vue";
          name = "volar";
          version = "2.0.14";
          sha256 = "sha256-UQGatAUuDCd5/sisp8UOTuP1gtNMxTpOHQLzO28eOYg=";
        };
      })
      (buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mshr-h";
          name = "VerilogHDL";
          version = "1.14.1";
          sha256 = "sha256-XAA33fA2kqIdJoVx9lwsl8c0PVKGkt39cg3UWypfoFU=";
        };
      })
    ];
  };
}
