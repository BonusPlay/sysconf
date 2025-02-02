{ agenix, nixpkgs-unstable, ... }:
[
  (import ./agenix.nix { inherit agenix; })
  (import ./beszel.nix { inherit nixpkgs-unstable; })
  (import ./ghidra.nix { inherit nixpkgs-unstable; })
  (import ./mautrix.nix)
  (import ./open-webui.nix)
]
