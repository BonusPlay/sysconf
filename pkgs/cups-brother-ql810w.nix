{
  stdenv,
  fetchurl,
  dpkg,
  lib,
  autoPatchelfHook,
  makeWrapper,
  perl,
  coreutils,
  gnugrep,
  gnused,
  ghostscript,
  which,
  file,
}:
stdenv.mkDerivation {
  name = "cups-brother-ql810w";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlfp100341/ql810wpdrv-3.1.5-0.i386.deb";
    hash = "sha256-hLNpTvz/u/vokbF6kgBKpNCSklsyKNEfI8KWSbHE/gI=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    cp -ar . $out

    WRAPPER=$out/opt/brother/PTouch/ql810w/cupswrapper/brother_lpdwrapper_ql810w
    LPDDIR=$out/opt/brother/PTouch/ql810w/lpd

    ln -s $LPDDIR/${stdenv.hostPlatform.linuxArch}/* $LPDDIR/

    substituteInPlace $WRAPPER \
      --replace-fail "PRINTER =~" "PRINTER = \"ql810w\"; #" \
      --replace-fail "basedir =~" "basedir = \"$out/opt/brother/PTouch/ql810w/\"; #" \
      --replace-fail "lpdconf = " "lpdconf = \$lpddir.'/'.\$LPDCONFIGEXE.\$PRINTER; #" \
      --replace-fail "\$DEBUG=0;" "\$DEBUG=5;" \
      --replace-fail /usr/bin/perl ${lib.getExe perl}

    substituteInPlace $LPDDIR/filter_ql810w \
      --replace-fail "BR_PRT_PATH =~" "BR_PRT_PATH = \"$out/opt/brother/PTouch/ql810w/\"; #" \
      --replace-fail "PRINTER =~" "PRINTER = \"ql810w\"; #" \
      --replace-fail /usr/bin/perl ${lib.getExe perl}

    wrapProgram $WRAPPER \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnugrep
          gnused
        ]
      }

    wrapProgram $LPDDIR/filter_ql810w \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          ghostscript
          gnugrep
          gnused
          which
          file
        ]
      }

    wrapProgram $LPDDIR/filter_ql810w --set NIX_REDIRECTS /opt=$out/opt
    wrapProgram $LPDDIR/brpapertoolcups --set NIX_REDIRECTS /opt=$out/opt
    wrapProgram $LPDDIR/brpapertoollpr_ql810w --set NIX_REDIRECTS /opt=$out/opt
    wrapProgram $LPDDIR/brprintconfpt1_ql810w --set NIX_REDIRECTS /opt=$out/opt
    wrapProgram $LPDDIR/rastertobrpt1 --set NIX_REDIRECTS /opt=$out/opt

    mkdir -p "$out/lib/cups/filter" "$out/share/cups/model"

    ln -s "$out/opt/brother/PTouch/ql810w/cupswrapper/brother_lpdwrapper_ql810w" \
      "$out/lib/cups/filter/"

    ln -s "$out/opt/brother/PTouch/ql810w/cupswrapper/brother_ql810w_printer_en.ppd" \
      "$out/share/cups/model/"

    runHook postInstall
  '';

  meta = {
    description = "Brother QL-810W drivers";
    homepage = "https://support.brother.com/g/b/producttop.aspx?c=us&lang=en&prod=lpql810weus";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    #license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ BonusPlay ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
