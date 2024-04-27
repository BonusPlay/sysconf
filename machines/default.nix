{ nixpkgs, home-manager, nixos-hardware, agenix, lanzaboote, authentik-nix, ... }:
let
  agenixOverlay = final: prev: {
    agenix = agenix.packages.${prev.system}.default;
  };

  pkgs = system: import nixpkgs {
    inherit system;

    overlays = [ agenixOverlay ];

    # I'd like to disable this and allow it occasionally, but turns out
    # it uses way more RAM during flake evaluation :(
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-25.9.0"
      ];
    };
  };

  nixTrick = {
    nix.registry.nixpkgs.flake = nixpkgs;
    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  };
in
{
  zeratul = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./zeratul
      ../modules/workstation.nix
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      nixTrick
    ];
  };

  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "aarch64-linux";
    modules = [
      ./kaldir
      ../modules/server.nix
      ../modules/mautrix-slack.nix
      ../modules/mautrix-googlechat.nix
      ../modules/mautrix-meta.nix
      agenix.nixosModules.default
      nixTrick
    ];
  };

  # kncyber VM
  braxis = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./braxis
      ../modules/server.nix
      agenix.nixosModules.default
      authentik-nix.nixosModules.default
    ];
  };

  # self-hosted development
  endion = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./endion
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # shakuras (git runner)
  shakuras = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./shakuras
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # nas
  glacius = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./glacius
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  ## downloader VM
  moria = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./moria
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # rpi whatsapp matrix bridge
  #redstone = nixpkgs.lib.nixosSystem {
  #  pkgs = pkgs "aarch64-linux";
  #  modules = [
  #    ./redstone
  #    ../modules/server.nix
  #    agenix.nixosModules.default
  #    nixos-hardware.nixosModules.raspberry-pi-4
  #  ];
  #};

  # nix builder
  scv = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./scv
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # network bridge
  warpprism = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./warpprism
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };
}
