{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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

  outputs = { self, nixpkgs, ... }@inputs: let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = (import ./machines inputs);

    colmena = lib.recursiveUpdate
      (builtins.mapAttrs (k: v: { imports = v._module.args.modules; }) self.nixosConfigurations)
      {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [];
          };
          nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
          nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
        };

        defaults.deployment.targetUser = "bonus";

        zeratul.deployment = {
          allowLocalDeployment = true;
          buildOnTarget = true;
          privilegeEscalationCommand = ["doas" "--"];
        };

        kaldir.deployment = {
          buildOnTarget = true;
        };
      };
  };
}
