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

    nvf-config = {
      url = "github:banana3216-2025/nvf-config";
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

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qml-go-lsp = {
      url = "github:cushycush/qml-language-server";
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
    nvf-config,
    helium,
    catppuccin,
    stylix,
    quickshell,
    zjstatus,
    qml-go-lsp,
    nix-flatpak,
    wallpapers,
    ...
  } @ inputs: {
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
        stylix.nixosModules.stylix
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

          environment.systemPackages = with pkgs; [
            eza
            btop
            git
            gh
          ];

          # Injects the zjstatus flake into the nixpkgs for convenience
          nixpkgs.overlays = [
            (final: prev: {
              zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
            })

            inputs.quickshell.overlays.default
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

    nixosConfigurations.NixOS-Laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        mainUser = "user";
      };

      system = "x86_64-linux";

      modules = [
        ./hosts/NixOS-Laptop/configuration.nix

        inputs.helium.nixosModules.default
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        ({
          mainUser,
          inputs,
          pkgs,
          ...
        }: {
          # Injects the zjstatus flake into the nixpkgs for convenience
          nixpkgs.overlays = [
            (final: prev: {
              zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
            })

            inputs.quickshell.overlays.default
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

    nixosConfigurations.NixOS-Mac = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        mainUser = "user";
      };

      system = "x86_64-linux";

      modules = [
        ./hosts/NixOS-Mac/configuration.nix

        nvf.nixosModules.default
        inputs.helium.nixosModules.default
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
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

    nixosConfigurations.NixOS-Testing = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        mainUser = "user";
      };

      modules = [
        ./hosts/NixOS-Testing/configuration.nix

        nvf.nixosModules.default
        home-manager.nixosModules.home-manager
        ({
          mainUser,
          pkgs,
          ...
        }: {
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
  };
}
