{
  description = "Personal system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Devenv
    devenv.url = "github:jkaye2012/devenv/main";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    # Home-manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs outputs system; };
        modules = [
          ./configuration.nix
          ./system-packages.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs system;
              extra-pkgs = [ ];
            };
            home-manager.users.jkaye = import ./home-manager/home.nix;
          }
        ];
      };

      homeConfigurations."jkaye@jkaye-framework" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [ ./home-manager/home.nix ];
        extraSpecialArgs = {
          inherit inputs outputs system;
          extra-pkgs = [
          ];
        };
      };

      homeConfigurations."jkaye@colwksdev001" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home-manager/home.nix
          ./home-manager/i3/default.nix
        ];
        extraSpecialArgs = {
          inherit inputs outputs system;
          extra-pkgs = with pkgs; [
            font-awesome
            mate.mate-power-manager
            powerline-fonts
            powerline-symbols
            ripgrep
            rofi
          ];
        };
      };

      homeConfigurations."gitpod" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home-manager/gitpod-home.nix ];
        extraSpecialArgs = {
          inherit inputs outputs system;
          extra-pkgs = [ ];
        };
      };
    };
}
