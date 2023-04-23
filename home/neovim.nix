{ pkgs, ... }:
pkgs.writeShellScriptBin "betterNvim" ''
  export PATH=$PATH:${pkgs.nodejs}/bin:${pkgs.cargo}/bin:${pkgs.clang}/bin
  exec ${pkgs.neovim}/bin/nvim "$@"
''
