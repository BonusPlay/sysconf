{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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

    authentik-nix = {
      #url = "github:nix-community/authentik-nix";
      url = "github:BonusPlay/authentik-nix/fix/nodejs_21";
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

        endion.deployment = {
          tags = [ "vm" "server" ];
        };

        glacius.deployment = {
          tags = [ "phys" "server" ];
        };

        kaldir.deployment = {
          tags = [ "phys" "server" ];
          buildOnTarget = true;
        };

        moria.deployment = {
          tags = [ "vm" "server" ];
        };

        #redstone.deployment = {
        #  tags = [ "phys" "server" ];
        #};

        scv.deployment = {
          tags = [ "vm" "server" ];
          buildOnTarget = true;
        };

        shakuras.deployment = {
          tags = [ "vm" "server" ];
        };

        warpprism.deployment = {
          tags = [ "vm" "server" ];
        };

        bunker.deployment = {
          tags = [ "vm" "server" ];
        };

        raven.deployment = {
          tags = [ "vm" "server" ];
        };

        nexus.deployment = {
          tags = [ "vm" "server" ];
        };

        zeratul.deployment = {
          allowLocalDeployment = true;
          buildOnTarget = true;
          tags = [ "phys" ];
          privilegeEscalationCommand = ["doas" "--"];
	};
      };
  };
}
