{ nixpkgs, ... }:
{
  programs.steam.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
        libglvnd
        llvmPackages_latest.libstdcxxClang
      ];
    };
  };
}
