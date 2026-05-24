{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.swww;
in {
  options.custom-modules.desktop.swww = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables swww wallpaper service";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [pkgs.awww];

      environment.sessionVariables = {
        WALLPAPER_MANAGER = "awww-daemon";
      };
    })
  ];
}
