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

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

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
    quickshell,
    nix-flatpak,
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
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        ({
          mainUser,
          inputs,
          pkgs,
          ...
        }: {
          fonts.packages = with pkgs; [
            nerd-fonts.symbols-only
            nerd-fonts.jetbrains-mono
          ];

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
