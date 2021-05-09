{
  description = "Aaqa Ishtyaq's nix system files";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    {
      homeConfigurations = {
        linux-server = inputs.home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, ... }:
            {
              imports = [
                ./modules/shared
              ];
            };
          system = "x86_64-linux";
          homeDirectory = "/home/aaqa";
          username = "aaqa";
        };
      };

      linux-desktop = self.homeConfigurations.linux-desktop.activationPackage;
    };
}
