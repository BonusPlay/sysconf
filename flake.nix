{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
    nixosConfigurations = (import ./machines inputs);
    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
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
        targetHost = "bunker";
      };

      endion.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "endion";
      };

      kaldir.deployment = {
        tags = [ "phys" "server" ];
        buildOnTarget = true;
        targetHost = "kaldir";
      };

      shakuras.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "shakuras";
      };

      raven.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "raven";
      };

      nexus.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "nexus";
      };

      glacius.deployment = {
        tags = [ "phys" "server" ];
        targetHost = "glacius";
      };

      prism.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "prism";
      };

      moria.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "moria";
      };

      plex.deployment = {
        tags = [ "vm" "server" ];
        targetHost = "plex";
      };
    } // builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) self.nixosConfigurations;
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
  };
}
