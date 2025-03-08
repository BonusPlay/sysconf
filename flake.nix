{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = (import ./machines inputs);
    #colmena = {
    #  meta = {
    #    nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    #    nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
    #    nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
    #  };
    #} // builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) self.nixosConfigurations;

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

        braxis.deployment = {
          tags = [ "vm" "server" ];
        };

        bunker.deployment = {
          tags = [ "vm" "server" ];
          targetHost = "bunker.warp.lan";
        };

        endion.deployment = {
          tags = [ "vm" "server" ];
        };

        kaldir.deployment = {
          tags = [ "phys" "server" ];
          buildOnTarget = true;
          targetHost = "kaldir.warp.lan";
        };

        shakuras.deployment = {
          tags = [ "vm" "server" ];
        };

        raven.deployment = {
          tags = [ "vm" "server" ];
        };

        nexus.deployment = {
          tags = [ "vm" "server" ];
        };

        glacius.deployment = {
          tags = [ "server" ];
          targetHost = "glacius.warp.lan";
        };

        artanis.deployment = {
          allowLocalDeployment = true;
          buildOnTarget = true;
          tags = [ "phys" ];
          privilegeEscalationCommand = ["doas" "--"];
        };

        zeratul.deployment = {
          allowLocalDeployment = true;
          buildOnTarget = true;
          tags = [ "phys" ];
          privilegeEscalationCommand = ["doas" "--"];
        };

        warpgate.deployment = {
          tags = [ "phys" ];
          targetHost = "192.168.10.9";
        };
      };
  };
}
