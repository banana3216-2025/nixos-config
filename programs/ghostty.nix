{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.terminals.ghostty;
in {
  options.custom-modules.terminals.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the ghostty terminal";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply Home Manager settings to.";
    };

    transparency = lib.mkOption {
      type = lib.types.str;
      default = "1.0";
      description = "set the transparency of the ghostty terminal";
    };

    font = lib.mkOption {
      description = "the text settings for ghostty";
      type = lib.types.submodule {
        options = {
          family = lib.mkOption {
            type = lib.types.str;
            description = "sets the font family for ghostty";
            default = "monospace";
          };

          size = lib.mkOption {
            type = lib.types.int;
            default = 11;
            description = "sets the font size for ghostty terminal";
          };
        };
      };
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.ghostty];

    xdg.terminal-exec = {
      enable = true;
      settings.default = ["com.mitchellh.ghostty.desktop"];
    };

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      xdg.configFile."ghostty/shaders/cursor_tail.glsl".text = builtins.readFile ../shared/ghostty-trail.glsl;

      xdg.configFile."ghostty/config".text = ''
        # Generated automatically via NixOS Module
        background-opacity = ${cfg.transparency}

        # Window Behavior
        confirm-close-surface = false

        # --- Shaders ---
        # FIX: Changed to absolute system path strings using Home Manager's config environment variables
        custom-shader = ${config.home-manager.users.${username}.xdg.configHome}/ghostty/shaders/cursor_tail.glsl
        custom-shader-animation = always
        # ----------------------------------

        # Font Configuration
        font-family = "${cfg.font.family}"
        font-size = ${toString cfg.font.size}

        # The basic colors (Catppuccin Mocha)
        foreground = #cdd6f4
        background = #1e1e2e
        selection-foreground = #1e1e2e
        selection-background = #f5e0dc

        copy-on-select = true
        right-click-action = copy

        cursor-color = #f5e0dc
        cursor-text = #1e1e2e
        cursor-style = block

        window-padding-color = extend

        # The 16 terminal colors
        palette = 0=#45475a
        palette = 8=#585b70
        palette = 1=#f38ba8
        palette = 9=#f38ba8
        palette = 2=#a6e3a1
        palette = 10=#a6e3a1
        palette = 3=#f9e2af
        palette = 11=#f9e2af
        palette = 4=#89b4fa
        palette = 12=#89b4fa
        palette = 5=#f5c2e7
        palette = 13=#f5c2e7
        palette = 6=#94e2d5
        palette = 14=#94e2d5
        palette = 7=#bac2de
        palette = 15=#a6adc8
      '';
    });
  };
}
