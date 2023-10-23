{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/binaryninja.nix {})
  ];
}
