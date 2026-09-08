{
  description = "Personal system configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # Devenv
    devenv.url = "github:jkaye2012/devenv/main";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    devenv.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    # Home-manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      unstableOverlay = final: prev: { inherit unstable; };
      overlays = [ unstableOverlay ];

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      # Shared nixpkgs settings for every nixosConfiguration; home-manager
      # reuses these via useGlobalPkgs.
      nixpkgsConfig = {
        nixpkgs = {
          inherit overlays;
          config.allowUnfree = true;
        };
      };

      extraSpecialArgs = {
        inherit inputs outputs system;
        user-info = {
          name = "Jordan Kaye";
          email = "jordan.kaye2@gmail.com";
        };
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
              nixpkgsConfig

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
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
      overlays.unstable = unstableOverlay;

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs system; };
          modules = [
            ./configuration.nix
            ./system-packages.nix
            nixpkgsConfig

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraSpecialArgs // {
                extra-pkgs = [
                  pkgs.lutris
                ];
              };
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
            nixpkgsConfig

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraSpecialArgs // {
                extra-aliases = {
                  rebuild = "sudo nixos-rebuild switch --flake /home/jkaye/nixos --impure";
                };
                extra-pkgs = [
                  pkgs.gparted
                  pkgs.playerctl
                  pkgs.spotify
                  pkgs.xfce.xfce4-systemload-plugin
                ];
                user-info = extraSpecialArgs.user-info // {
                  email = "jkaye@belvederetrading.com";
                };
              };
              home-manager.users.jkaye = import ./home-manager/home.nix;
            }
          ];
        };
      }
      // vpsConfigs;

      homeConfigurations."jkaye@jkaye-framework" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = extraSpecialArgs // {
          extra-pkgs = [
            pkgs.lutris
            pkgs.steam
          ];
        };

        modules = [ ./home-manager/home.nix ];
      };

      homeConfigurations."gitpod" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;

        modules = [ ./home-manager/gitpod-home.nix ];
      };
    };
}
