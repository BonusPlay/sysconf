{ agenix, nixpkgs-unstable, web-utils, ... }:
[
  (import ./agenix.nix { inherit agenix; })
  (import ./beszel.nix { inherit nixpkgs-unstable; })
  (import ./ghidra.nix { inherit nixpkgs-unstable; })
  (import ./open-webui.nix)
  (import ./web-utils.nix { inherit web-utils; })
]
