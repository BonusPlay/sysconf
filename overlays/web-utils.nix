{ web-utils }:
final: prev: {
  web-utils = web-utils.packages.${prev.stdenv.hostPlatform.system}.default;
}
