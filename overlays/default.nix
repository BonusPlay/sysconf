{ agenix, nixpkgs-unstable, ... }:
[
  (import ./agenix.nix { inherit agenix; })
  (import ./ghidra.nix { inherit nixpkgs-unstable; })
  (import ./mautrix.nix)
  (final: prev: { onlyoffice-documentserver = prev.callPackage ../pkgs/hax.nix {}; })
]
