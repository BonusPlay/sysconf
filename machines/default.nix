{ nixpkgs
, agenix
, ... }@inputs:
{
  # oci vm
  kaldir = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./kaldir
      ../modules/server.nix
      ../modules/mautrix-slack.nix
      ../modules/litellm.nix
      ../modules/podman.nix
      agenix.nixosModules.default
    ];
  };

  # kncyber VM
  braxis = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./braxis
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # self-hosted development
  endion = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./endion
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # shakuras (git runner)
  shakuras = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./shakuras
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # nextcloud + onlyoffice
  bunker = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./bunker
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # pki
  raven = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./raven
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # home-assistant
  nexus = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./nexus
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # nas
  glacius = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./glacius
      ../modules/server.nix
      ../modules/fan2go.nix
      agenix.nixosModules.default
    ];
  };

  # prism mTLS proxy
  prism = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./prism
      ../modules/server.nix
      agenix.nixosModules.default
    ];
  };

  # moria downloader VM
  moria = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./moria
      ../modules/server.nix
      ../modules/podman.nix
      agenix.nixosModules.default
    ];
  };

  # plex VM
  plex = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./plex
      ../modules/server.nix
      ../modules/podman.nix
      ../modules/watchtower.nix
      agenix.nixosModules.default
    ];
  };
}
