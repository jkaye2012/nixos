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
      lib = nixpkgs.lib;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        inherit inputs outputs system;
        extra-pkgs = [ ];
        extra-aliases = { };
      };

      vpsConfigs =
        let
          vpsNames = lib.pipe (builtins.readDir ./hardware-configurations) [
            builtins.attrNames
            (builtins.map (filename: nixpkgs.lib.removeSuffix ".nix" filename))
          ];
        in
        lib.genAttrs vpsNames (
          hostname:
          lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                outputs
                system
                hostname
                ;
            };
            modules = [
              ./nixos-configurations/vps-configuration.nix
              ./system-packages.nix

              home-manager.nixosModules.home-manager
              {
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = extraSpecialArgs // {
                  extra-aliases = {
                    rebuild = "sudo nixos-rebuild switch --flake /home/jkaye/nixos";
                  };
                };
                home-manager.users.jkaye = import ./home-manager/home.nix;
              }
            ];
          }
        );
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs system; };
          modules = [
            ./configuration.nix
            ./system-packages.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraSpecialArgs;
              home-manager.users.jkaye = import ./home-manager/home.nix;
            }
          ];
        };

        colwksdev001 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs system; };
          modules = [
            ./bt-configuration.nix
            ./system-packages.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraSpecialArgs // {
                extra-pkgs = [
                  pkgs.playerctl
                  pkgs.spotify
                ];
              };
              home-manager.users.jkaye = import ./home-manager/home.nix;
            }
          ];
        };
      }
      // vpsConfigs;

      homeConfigurations."jkaye@jkaye-framework" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;

        modules = [ ./home-manager/home.nix ];
      };

      homeConfigurations."gitpod" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;

        modules = [ ./home-manager/gitpod-home.nix ];
      };
    };
}
