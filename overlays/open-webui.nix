_: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    # taken from: https://github.com/NixOS/nixpkgs/issues/312068#issuecomment-2365236799
    (_: python-prev: {
      rapidocr-onnxruntime = python-prev.rapidocr-onnxruntime.overridePythonAttrs (self: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64
          then []
          else ["rapidocr_onnxruntime"];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
        meta = self.meta // {broken = false; badPlatforms = [];};
      });

      chromadb = python-prev.chromadb.overridePythonAttrs (self: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64
          then []
          else ["chromadb"];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
        meta = self.meta // {broken = false;};
      });

      langchain-chroma = python-prev.langchain-chroma.overridePythonAttrs (_: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64
          then []
          else ["langchain_chroma"];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
      });
    })
    # hack for modules/litellm.nix
    (_: python-prev: {
      litellm = python-prev.litellm.overridePythonAttrs (org: {
        dependencies = org.dependencies ++ org.optional-dependencies.proxy;
      });
    })
  ];
}
