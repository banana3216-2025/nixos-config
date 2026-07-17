{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.shell.zsh;
in {
  options.custom-modules.shell.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the kitty terminal and  settings for root and users.";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply Home Manager settings to.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        ls = "eza -lh";
        clear-history = "/etc/nixos/shared/clear_history.sh";
      };
      description = "Shell aliases to add to Zsh.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    users.users = lib.genAttrs cfg.targetUsers (username: {
      shell = pkgs.zsh;
    });

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = cfg.aliases;

        history = {
          size = 10000;
          path = "$HOME/.zsh_history";
        };
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true; # Fast, persistent nix caching module
        enableZshIntegration = true; # Tells Home Manager to auto-patch your .zshrc
      };
    });
  };
}
