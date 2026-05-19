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
    # Ensure dconf is enabled at the system level for theme changes to register
    programs.dconf.enable = true;

    # Inject Home Manager configuration dynamically for specified users
    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      # Enable GTK configuration module
      gtk = {
        enable = true;

        theme = {
          name = "Tokyonight-Dark";
          package = pkgs.tokyonight-gtk-theme;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        cursorTheme = {
          name = "Numix-Cursor";
          package = pkgs.numix-cursor-theme;
        };

        # Force dark mode hints for newer GTK3 and GTK4 apps
        gtk3.extraConfig = {
          Settings = "gtk-application-prefer-dark-theme=1;";
        };
        gtk4.extraConfig = {
          Settings = "gtk-application-prefer-dark-theme=1;";
        };
      };

      # Set session variables so window managers (like Hyprland/Sway) inherit the theme
      home.sessionVariables = {
        GTK_THEME = "Tokyonight-Dark";
      };

      # Force Libadwaita / GTK4 apps to respect global dark mode
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    });
  };
}
