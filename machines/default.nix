{ nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, agenix, lanzaboote, colmena, ... }:
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
  agenixExe = {
    nixpkgs.overlays = [
      (final: prev: {
        agenix = agenix.packages.${prev.system}.default;
      })
    ];
  };
in
{
  zeratul = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = addUnstable "x86_64-linux";
    modules = [
      ./zeratul
      ../modules/workstation.nix
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      nixTrick
      agenixExe
    ];
  };

  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = addUnstable "aarch64-linux";
    modules = [
      ./kaldir
      ../modules/server.nix
      ../modules/mautrix-slack.nix
      ../modules/mautrix-googlechat.nix
      agenix.nixosModules.default
      nixTrick
    ];
  };

  # kncyber VM
  braxis = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./braxis
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # shakuras (git runner)
  shakuras = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./shakuras
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # self-hosted development
  endion = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./endion
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # nas
  glacius = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./glacius
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # downloader VM
  moria = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./moria
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # rpi whatsapp matrix bridge
  redstone = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = addUnstable "aarch64-linux";
    modules = [
      ./redstone
      ../modules/server.nix
      agenix.nixosModules.default
      nixos-hardware.nixosModules.raspberry-pi-4
    ];
  };
}
