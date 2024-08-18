{ nixpkgs
, home-manager
, nixos-hardware
, agenix
, lanzaboote
, authentik-nix
, nixvim
, nix-index-database
, ... }:
let
  agenixOverlay = final: prev: {
    agenix = agenix.packages.${prev.system}.default;
  };
  ghidraOverlay = final: prev: {
    ghidra-extensions = {
      arcompact = final.callPackage ../pkgs/ghidra-arcompact.nix {};
      findcrypt = final.callPackage ../pkgs/ghidra-findcrypt.nix {};
    } // prev.ghidra-extensions;
  };
  pkgs = system: import nixpkgs {
    inherit system;
    overlays = [ agenixOverlay ghidraOverlay ];
    config.allowUnfree = true;
  };
in
{
  artanis = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./artanis
      ../modules/workstation.nix
      nixos-hardware.nixosModules.framework-12th-gen-intel
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
    ];
    specialArgs = {
      inherit nixvim nix-index-database;
    };
  };

  zeratul = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./zeratul
      ../modules/workstation.nix
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
    ];
    specialArgs = {
      inherit nixvim nix-index-database;
    };
  };

  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "aarch64-linux";
    modules = [
      ./kaldir
      ../modules/server.nix
      ../modules/mautrix-slack.nix
      agenix.nixosModules.default
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

  # gitea runner-x
  #runner-x = nixpkgs.lib.nixosSystem {
  #  pkgs = pkgs "x86_64-linux";
  #  modules = [
  #    ./runner-x
  #    ../modules/server.nix
  #    agenix.nixosModules.default
  #  ];
  #};

  vortex = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./vortex
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

  # nextcloud + onlyoffice
  bunker = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./bunker
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # pki
  raven = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./raven
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # home-assistant
  nexus = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./nexus
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };
}
