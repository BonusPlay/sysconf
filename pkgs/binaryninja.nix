{ pkgs, lib, stdenv, requireFile, writeScript, buildFHSUserEnv, makeDesktopItem }:
let
  unwrapped = stdenv.mkDerivation rec {
    pname = "BinaryNinja";
    version = "3.4.4271";
    src = requireFile rec {
      name = "BinaryNinja-personal-dev.zip";
      sha256 = "153l2vx2ds3mzwzm49npz7xx47shqlp9y43faa4n82i8igd15fya";
      message = ''
        Please download your copy of BinaryNinja personal from your personal link
        and run "nix-prefetch-url file:///${name}" to add it to nix store.
      '';
    };

    nativeBuildInputs = with pkgs; [ unzip ];

    buildCommand = ''
      mkdir -vp "$out"
      unzip "$src" -d "$out"
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "BinaryNinja";
        exec = "binaryninja";
        icon = "binaryninja";
        desktopName = "BinaryNinja";
        genericName = "BinaryNinja";
        categories = [ "Development" ];
      })
    ];
  };
in
buildFHSUserEnv rec {
  name = "BinaryNinja-${unwrapped.version}";

  targetPkgs = pkgs: with pkgs; [
    unwrapped
  ];

  runScript = ''
    exec $@
  '';
}
