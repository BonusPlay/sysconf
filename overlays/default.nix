{ agenix, nixpkgs-unstable, web-utils, ... }:
[
  (import ./agenix.nix { inherit agenix; })
  (import ./beszel.nix)
  (import ./ghidra.nix)
  (import ./matrix.nix)
  (import ./pkgs-unstable.nix { inherit nixpkgs-unstable; })
  (import ./web-utils.nix { inherit web-utils; })
]
