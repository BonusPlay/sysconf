{ lib
, fetchgit
, ghidra
, ant
}:
ghidra.buildGhidraExtension {
  pname = "arcompact";
  version = lib.getVersion ghidra;

  # this is nothing special, just replaces a few files to convert it into external ghidra module
  # feel free to ping me if you want a copy
  src = fetchgit {
    url = "ssh://forgejo@git.warp.lan:2222/Bonus/ghidra-arcompact.git";
    hash = "sha256-CNAgjhqApFQjkuWZuat0UbSmbCQd+CeO6eKNOY1Xn68=";
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
    homepage = "https://github.com/NationalSecurityAgency/ghidra/pull/3006";
    license = licenses.gpl3;
  };
}

