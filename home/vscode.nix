{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      wholroyd.jinja
    ];
  };
}
