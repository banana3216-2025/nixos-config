{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.stylix;
in {
  options.custom-modules.desktop.stylix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables System theme configuration with stylix.";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Home manager users to apply the theming to.";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      image = pkgs.nixos-artwork.wallpapers.gnome-dark.src;
      polarity = "dark";

      fonts = {
        sizes = {
          applications = 11;
          desktop = 11;
          popups = 10;
        };
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };

      targets = {
        gtk.enable = true;
        gnome.enable = true;
        console.enable = true;
        kmscon.enable = true;
      };
    };

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      home.pointerCursor.enable = true;

      stylix.targets = {
        gtk.enable = true;
        gnome.enable = true;
      };
    });
  };
}
