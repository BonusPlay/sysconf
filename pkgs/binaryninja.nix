{ lib,
  buildFHSEnv,
  writeScript,
}:
buildFHSEnv {
  name = "binaryninja";
  targetPkgs = pkgs: with pkgs; [
    dbus
    fontconfig
    freetype
    libGL
    libxkbcommon
    python3
    xorg.libX11
    xorg.libxcb
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    wayland
    zlib
  ];
  runScript = writeScript "binaryninja.sh" ''
    set -e
    exec "$HOME/binaryninja/binaryninja"
  '';
  #desktopItems = [
  #  (makeDesktopItem {
  #    name = "BinaryNinja";
  #    exec = "binaryninja";
  #    icon = "binaryninja";
  #    desktopName = "BinaryNinja";
  #    genericName = "BinaryNinja";
  #    categories = [ "Development" ];
  #  })
  #];
  meta = {
    description = "BinaryNinja";
    platforms = [ "x86_64-linux" ];
  };
}
