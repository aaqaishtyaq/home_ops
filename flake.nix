{
  description = "Aaqa Ishtyaq's nix system files";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    {
      # nixos system configurations
      nixosConfigurations = {
        pix = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/pix
            ./modules/x11
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaqa = {
                imports = [
                  ./modules/common/default.nix
                ];
              };
            }
          ];
        };
      };

      nixosConfigurations = {
        altair = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/altair
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
                home-manager.users.aaqa = {
                imports = [
                  ./modules/common/default.nix
                ];
              };
            }
          ];
        };
      };

      homeConfigurations = {
        linux-server = inputs.home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, ... }:
            {
              imports = [
                ./modules/common
              ];
            };
          system = "x86_64-linux";
          homeDirectory = "/home/aaqa";
          username = "aaqa";
          stateVersion = "22.11";
        };

        ubuntu-server = inputs.home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, ... }:
            {
              imports = [
                ./modules/common
              ];
            };
          system = "x86_64-linux";
          homeDirectory = "/home/ubuntu";
          username = "ubuntu";
          stateVersion = "22.11";
        };
      };

      linux-server = self.homeConfigurations.linux-server.activationPackage;
      ubuntu-server = self.homeConfigurations.ubuntu-server.activationPackage;
    };
}
