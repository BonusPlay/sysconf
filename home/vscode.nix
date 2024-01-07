{ pkgs, lib,  ... }:
let
  inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;
in
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      wholroyd.jinja
      rust-lang.rust-analyzer
      (buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mshr-h";
          name = "VerilogHDL";
          version = "1.13.0";
          sha256 = "sha256-axmXLwVmMCmf7Vov0MbSaqM921uKUDeggxhCNoc6eYA=";
        };
      })
    ];
  };
}
