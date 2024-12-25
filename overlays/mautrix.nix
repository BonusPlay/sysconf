final: prev: {
  mautrix-meta = prev.mautrix-meta.overrideAttrs(old: {
    version = "v0.4.3";
    src = prev.fetchFromGitHub {
      owner = "mautrix";
      repo = "meta";
      rev = "v0.4.3";
      hash = "sha256-aq1tmw19evTxmSNpDQyFdjyc0ow1Rsm2jlodglcj084=";
    };
    vendorHash = "sha256-1ulBTkhb/MDmu26R8v8HUt1HkRNpsufpp+EzTQrlaCQ=";
  });
}
