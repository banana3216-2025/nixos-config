{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.launchers.wofi;
in {
  options.custom-modules.launchers.wofi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the wofi program launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.wofi];
  };
}
