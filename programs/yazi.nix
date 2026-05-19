{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.editors.yazi;
in {
  options.custom-modules.editors.yazi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the yazi file browser";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to allowed to use yazi";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.yazi];
  };
}
