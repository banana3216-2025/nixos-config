{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.terminals.kitty;
in {
  options.custom-modules.terminals.kitty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the kitty terminal";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply Home Manager settings to.";
    };

    transparency = lib.mkOption {
      type = lib.types.str;
      default = "1.0";
      description = "set the transparency of the kitty terminal";
    };

    font = lib.mkOption {
      description = "the text settings for kitty";
      type = lib.types.submodule {
        options = {
          family = lib.mkOption {
            type = lib.types.str;
            description = "sets the font family for kitty";
            default = "monospace";
          };

          size = lib.mkOption {
            type = lib.types.int;
            default = 11;
            description = "sets the font size for kitty terminal";
          };
        };
      };
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.kitty];

    xdg.terminal-exec = {
      enable = true;
      settings.default = ["kitty.desktop"];
    };

    # Inject Home Manager configuration dynamically for specified users
    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      xdg.configFile."kitty/kitty.conf".text = ''
        # Generated automatically via NixOS Module
        background_opacity ${cfg.transparency}

        copy_on_select clipboard
        confirm_os_window_close 0

        cursor_trail 2

        # The basic colors
        foreground              #cdd6f4
        background              #1e1e2e
        selection_foreground    #1e1e2e
        selection_background    #f5e0dc

        # Cursor colors
        cursor                  #f5e0dc
        cursor_text_color       #1e1e2e

        # Scrollbar colors
        scrollbar_handle_color  #9399b2
        scrollbar_track_color   #45475a

        # URL color when hovering with mouse
        url_color               #f5e0dc

        # Kitty window border colors
        active_border_color     #b4befe
        inactive_border_color   #6c7086
        bell_border_color       #f9e2af

        # OS Window titlebar colors
        wayland_titlebar_color system
        macos_titlebar_color system

        # Tab bar colors
        active_tab_foreground   #11111b
        active_tab_background   #cba6f7
        inactive_tab_foreground #cdd6f4
        inactive_tab_background #181825
        tab_bar_background      #11111b

        # Colors for marks (marked text in the terminal)
        mark1_foreground #1e1e2e
        mark1_background #b4befe
        mark2_foreground #1e1e2e
        mark2_background #cba6f7
        mark3_foreground #1e1e2e
        mark3_background #74c7ec

        # The 16 terminal colors

        # black
        color0 #45475a
        color8 #585b70

        # red
        color1 #f38ba8
        color9 #f38ba8

        # green
        color2  #a6e3a1
        color10 #a6e3a1

        # yellow
        color3  #f9e2af
        color11 #f9e2af

        # blue
        color4  #89b4fa
        color12 #89b4fa

        # magenta
        color5  #f5c2e7
        color13 #f5c2e7

        # cyan
        color6  #94e2d5
        color14 #94e2d5

        # white
        color7  #bac2de

        # Font Configuration
        font_family      ${cfg.font.family}
        font_size        ${toString cfg.font.size}

        scrollback_lines 1000
        enable_audio_bell no
      '';
    });
  };
}
