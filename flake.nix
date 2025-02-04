{
  description = "Personal system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Devenv
    devenv.url = "github:jkaye2012/devenv/main";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    # Home-manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let 
      inherit (self) outputs; 
      system = "x86_64-linux";
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs outputs system; };
      modules = [
        ./configuration.nix
        ./system-packages.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs outputs system; };
          home-manager.users.jkaye = import ./home-manager/home.nix;
        }
      ];
    };

    homeConfigurations."jkaye" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home-manager/home.nix ];
      extraSpecialArgs = { inherit inputs outputs system; };
    };
  };
}
