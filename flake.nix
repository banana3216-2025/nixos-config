{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, ... }@inputs: {
    nixosConfigurations.NixOS-Testing = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; mainUser = "user"; };

      modules = [
        ./hosts/NixOS-Testing/configuration.nix

        nvf.nixosModules.default
        home-manager.nixosModules.home-manager
        ({mainUser, ...}: { 
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${mainUser} = {
            home.stateVersion = "25.11";
            home.username = "${mainUser}";
            home.homeDirectory = "/home/${mainUser}";
          };

          home-manager.users.root = {
            home.stateVersion = "25.11";
            home.username = "root";
            home.homeDirectory = "/root";
          };

        })
      ];
    };

    nixosConfigurations.NixOS-Desktop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; mainUser = "a"; };

      modules = [
        ./hosts/NixOS-Desktop/configuration.nix

        nvf.nixosModules.default
        home-manager.nixosModules.home-manager
        ({mainUser, ...}: { 
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${mainUser} = {
            home.stateVersion = "25.11";
            home.username = "${mainUser}";
            home.homeDirectory = "/home/${mainUser}";
          };

          home-manager.users.root = {
            home.stateVersion = "25.11";
            home.username = "root";
            home.homeDirectory = "/root";
          };

        })
      ];
    };


  };
}
