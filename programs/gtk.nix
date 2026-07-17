{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.gtk;
in {
  options.custom-modules.desktop.gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables GTK theme, icon, and cursor configurations via Home Manager.";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply GTK theming settings to.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      gtk = {
        enable = true;

        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        cursorTheme = {
          name = "Numix-Cursor";
          package = pkgs.numix-cursor-theme;
        };

        gtk3.extraConfig = {
          Settings = "gtk-application-prefer-dark-theme=1;";
        };
        gtk4.extraConfig = {
          Settings = "gtk-application-prefer-dark-theme=1;";
        };
      };

      home.sessionVariables = {
        GTK_THEME = "Tokyonight-Dark";
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    });
  };
}
