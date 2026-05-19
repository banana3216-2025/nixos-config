{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.editors.thunar;
in {
  options.custom-modules.editors.thunar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables the thunar file browser";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.xfce.thunar];
  };
}
