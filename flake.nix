{
  description = "Aaqa Ishtyaq's nix system files";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";

    # nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Environment/system management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, ... }@inputs:
  let
    # Configuration for `nixpkgs` mostly used in personal configs.
    nixpkgsConfig = with inputs; {
      config = { allowUnfree = true; };
      overlays = self.overlays ++ [
        (
          final: prev:
          let
            system = prev.stdenv.system;
            nixpkgs-stable = if system == "x86_64-darwin" then nixpkgs-stable-darwin else nixos-stable;
          in {
            master = nixpkgs-master.legacyPackages.${system};
            stable = nixpkgs-stable.legacyPackages.${system};
          }
        )
      ];
    };
  in {
    homeConfigurations = {
      cloudVM = inputs.home-manager.lib.homeManagerConfiguration {
        configuration = { pkgs, config, ...}:
        {
          nixpkgs.config = import ./config/nix/config.nix;
          imports = [
            ./modules
          ];
          system = "x86_64-linux";
          homeDirectory = "/home/ubuntu";
          username = "ubuntu";
        };
      };
    };

    cloudVM = self.homeConfigurations.cloudVM.activationPackage;
  };
}
