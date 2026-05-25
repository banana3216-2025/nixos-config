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

        # Font Configuration
        font_family      ${cfg.font.family}
        font_size        ${toString cfg.font.size}

        scrollback_lines 10000
        enable_audio_bell no
      '';
    });
  };
}
