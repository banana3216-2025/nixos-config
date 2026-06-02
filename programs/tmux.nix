{
  config,
  lib,
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

      extraConfig = builtins.readFile (
        ../hosts + "/${config.networking.hostName}/program-data/tmux.conf"
      );
    };
  };
}
