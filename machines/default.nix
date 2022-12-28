{ nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nur, agenix, p4net, ... }:
{
  artanis = let
    system = "x86_64-linux";
  in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        nixpkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        ./artanis 
        nixos-hardware.nixosModules.framework-12th-gen-intel
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        agenix.nixosModule
        p4net.nixosModule
      ];
    };

  kaldir = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ./kaldir
      agenix.nixosModule
      p4net.nixosModule
    ];
  };

  vanass = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./vanass
      agenix.nixosModule
    ];
  };

  #shakuras
  #endion
}
