{ agenix, nixpkgs-unstable, ... }:
[
  (import ./agenix.nix { inherit agenix; })
  (import ./ghidra.nix { inherit nixpkgs-unstable; })
  (import ./mautrix.nix)
]
