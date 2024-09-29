{ lib
, fetchFromGitHub
, ghidra
, ant
}:
ghidra.buildGhidraExtension {
  pname = "arcompact";
  version = lib.getVersion ghidra;

  src = fetchFromGitHub {
    owner = "BonusPlay";
    repo = "ghidra-arcompact";
    rev = "e500daaa68797a8f8ce33064d9b3a653b2313dd8";
    hash = "sha256-L/GUoq1KLeUlFOUm0g7WsifaR0XodvTSN8cm7BSg5Q8=";
  };

  # compile sleigh
  configurePhase = ''
    runHook preConfigure

    pushd data
    ${ant}/bin/ant -f buildLanguage.xml -Dghidra.install.dir=${ghidra}/lib/ghidra sleighCompile
    popd

    runHook postConfigure
  '';

  meta = with lib; {
    author = "niooss-ledger";
    description = "ARCompact instruction set support for ghidra";
    homepage = "https://github.com/BonusPlay/ghidra-arcompact";
    license = licenses.gpl3;
  };
}
