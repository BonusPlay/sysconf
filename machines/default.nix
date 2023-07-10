{ nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, agenix, arion, lanzaboote, ... }:
let
  addUnstable = system: {
    nixpkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  nixTrick = ({ ... }: {
    nix.registry.nixpkgs.flake = nixpkgs;
    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  });
in
{
  artanis = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = addUnstable "x86_64-linux";
    modules = [
      ./artanis
      ../modules/base.nix
      ../modules/workstation.nix
      ../modules/warp-net.nix
      nixos-hardware.nixosModules.framework-12th-gen-intel
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      nixTrick
    ];
  };

  zeratul = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = addUnstable "x86_64-linux";
    modules = [
      ./zeratul
      ../modules/base.nix
      ../modules/workstation.nix
      ../modules/warp-net.nix
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      nixTrick
    ];
  };

  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = addUnstable "x86_64-linux";
    modules = [
      ./kaldir
      agenix.nixosModules.default
      nixTrick
    ];
  };

  # vanass

  # kncyber VM
  braxis = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./braxis
      agenix.nixosModules.default
      arion.nixosModules.arion
      nixTrick
    ];
  };

  # shakuras (git runner)
  shakuras = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./shakuras
      agenix.nixosModules.default
      nixTrick
    ];
  };

  # self-hosted development
  endion = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./endion
      agenix.nixosModules.default
      nixTrick
    ];
  };

  # nas
  glacius = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./glacius
      agenix.nixosModules.default
      nixTrick
    ];
  };
}
