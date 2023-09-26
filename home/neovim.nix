{ pkgs, ... }:
let
  packages = with pkgs; [ nodejs cargo ccls clang clang-tools unzip rust-analyzer rustc pyright ];
  helpers = map (p: "${p}/bin") packages;
  path = builtins.concatStringsSep ":" helpers;
in
pkgs.writeShellScriptBin "betterNvim" ''
  export PATH=$PATH:${path}
  exec ${pkgs.neovim}/bin/nvim "$@"
''
