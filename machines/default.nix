{ nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nur, agenix, p4net, arion, ... }:
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
      nixos-hardware.nixosModules.framework-12th-gen-intel
      nur.nixosModules.nur
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      p4net.nixosModule
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
      p4net.nixosModule
      nixTrick
    ];
  };

  # p4net exit node
  vanass = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./vanass
      agenix.nixosModules.default
      nixTrick
    ];
  };

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

  # shakuras

  # self-hosted development
  endion = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./endion
      agenix.nixosModules.default
      nixTrick
    ];
  };
}
