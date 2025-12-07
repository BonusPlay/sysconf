{ agenix }:
final: prev: {
  agenix = agenix.packages.${prev.stdenv.hostPlatform.system}.default;
}
