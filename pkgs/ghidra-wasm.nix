{ lib
, fetchFromGitHub
, ghidra
, ant
}:
ghidra.buildGhidraExtension {
  pname = "wasm";
  version = lib.getVersion ghidra;

  src = fetchFromGitHub {
    owner = "nneonneo";
    repo = "ghidra-wasm-plugin";
    rev = "v2.3.1";
    hash = "sha256-aoSMNzv+TgydiXM4CbvAyu/YsxmdZPvpkZkYEE3C+V4=";
  };

  nativeBuildInputs = [ ant ];

  # compile sleigh
  configurePhase = ''
    runHook preConfigure

    pushd data
    ant -f build.xml -Dghidra.install.dir=${ghidra}/lib/ghidra sleighCompile
    popd

    runHook postConfigure
  '';

  meta = with lib; {
    description = "Ghidra Wasm plugin with disassembly and decompilation support";
    homepage = "https://github.com/nneonneo/ghidra-wasm-plugin";
    downloadPage = "https://github.com/nneonneo/ghidra-wasm-plugin/releases/tag/v2.3.1";
    license = licenses.gpl3;
  };
}
