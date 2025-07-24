{ nixpkgs
, nixpkgs-unstable
, agenix
, ... }@inputs:
let
  pkgs = system: import nixpkgs {
    inherit system;
    overlays = import ../overlays inputs;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "olm-3.2.16" ];
    config.allowUnfreePredicate = pkg: builtins.elem (system.lib.getName pkg) [
      "corefonts"
    ];
  };
in
{
  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "aarch64-linux";
    modules = [
      ./kaldir
      ../modules/server.nix
      ../modules/mautrix-slack.nix
      ../modules/litellm.nix
      ../modules/beszel-hub.nix
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

  # nas
  glacius = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./glacius
      ../modules/server.nix
      ../modules/fan2go.nix
      agenix.nixosModules.default
    ];
  };

  # prism mTLS proxy
  prism = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./prism
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # moria downloader VM
  moria = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./moria
      ../modules/server.nix
      ../modules/podman.nix
      agenix.nixosModules.default
    ];
  };

  # plex VM
  plex = nixpkgs.lib.nixosSystem {
    pkgs = pkgs "x86_64-linux";
    modules = [
      ./plex
      ../modules/server.nix
      ../modules/podman.nix
      agenix.nixosModules.default
    ];
  };
}
