{ web-utils }:
final: prev: {
  web-utils = web-utils.packages.${prev.system}.default;
}
