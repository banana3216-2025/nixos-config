{
  description = "A multi host nix flake with hyprland, NVF(nvim), helium browser, and wallpapers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #hyprland = {
    #url = "github:hyprwm/Hyprland";
    #inputs.nixpkgs.follows = "nixpkgs";
    #};

    wallpapers.url = "github:banana3216-2025/wallpapers";
    wallpapers.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    helium,
    catppuccin,
    wallpapers,
    ...
  } @ inputs: {
    nixosConfigurations.NixOS-Testing = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        mainUser = "user";
      };

      modules = [
        ./hosts/NixOS-Testing/configuration.nix

        nvf.nixosModules.default
        home-manager.nixosModules.home-manager
        ({mainUser, ...}: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${mainUser} = {
            home.stateVersion = "26.05";
            home.username = "${mainUser}";
            home.homeDirectory = "/home/${mainUser}";
          };

          home-manager.users.root = {
            home.stateVersion = "26.05";
            home.username = "root";
            home.homeDirectory = "/root";
          };
        })
      ];
    };

    nixosConfigurations.NixOS-Desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        mainUser = "a";
      };

      system = "x86_64-linux";

      modules = [
        ./hosts/NixOS-Desktop/configuration.nix

        nvf.nixosModules.default
        inputs.helium.nixosModules.default
        home-manager.nixosModules.home-manager
        ({
          mainUser,
          inputs,
          ...
        }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.backupFileExtension = "backup";

          home-manager.extraSpecialArgs = {inherit inputs;};

          home-manager.users.${mainUser} = {
            home.stateVersion = "26.05";
            home.username = "${mainUser}";
            home.homeDirectory = "/home/${mainUser}";

            xdg.configFile.".gtkrc-2.0".enable = false;
            # download wallpapers from github
            home.file."Pictures/Wallpapers".source = inputs.wallpapers;
          };

          home-manager.users.root = {
            home.stateVersion = "26.05";
            home.username = "root";
            home.homeDirectory = "/root";
          };
        })
      ];
    };
  };
}
