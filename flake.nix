{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    web-utils = {
      url = "github:bonusplay/web-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, colmena, ... }@inputs: let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = import ./machines inputs;
    colmena = lib.recursiveUpdate {
      meta = {
        nixpkgs = import nixpkgs { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
      };
      defaults.deployment.targetUser = "bonus";

      braxis.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "braxis";
      };

      bunker.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "bunker.internal";
      };

      endion.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "endion.internal";
      };

      kaldir.deployment = {
        tags = [ "phys" "server" ];
        buildOnTarget = true;
        targetHost = "kaldir.internal";
      };

      shakuras.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "shakuras.internal";
      };

      raven.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "raven.internal";
      };

      nexus.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "nexus.internal";
      };

      glacius.deployment = {
        tags = [ "phys" "server" ];
        targetHost = "glacius.internal";
      };

      prism.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "prism.internal";
      };

      moria.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "moria.internal";
      };

      plex.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "plex.internal";
      };
    } (builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) self.nixosConfigurations);
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
  };
}
