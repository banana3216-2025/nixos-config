{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.shell.tmux;
in {
  options.custom-modules.shell.tmux = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables the the Tmux terminal multiplexer";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator

        catppuccin
        prefix-highlight
      ];

      extraConfig = builtins.readFile (
        ../hosts + "/${config.networking.hostName}/program-data/tmux.conf"
      );
    };
  };
}
