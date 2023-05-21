{ pkgs, ... }:
let
  packages = with pkgs; [ nodejs cargo clang clang-tools unzip ];
  helpers = map (p: "${p}/bin") packages;
  path = builtins.concatStringsSep ":" helpers;
in
pkgs.writeShellScriptBin "betterNvim" ''
  export PATH=$PATH:${path}
  exec ${pkgs.neovim}/bin/nvim "$@"
''
