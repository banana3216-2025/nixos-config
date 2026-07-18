{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.gtk;
in {
  options.custom-modules.desktop.gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables system-wide theming via Stylix.";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply settings to";
    };
  };

  imports = [./stylix.nix];

  config = lib.mkIf cfg.enable {
    warnings = [
      "The option custom-modules.desktop.gtk.enable is obsolete. Please Use stylix.nix and remove gtk.nix from your configuration.nix."
    ];

    # Safe structure that avoids the "does not exist" evaluation error
    custom-modules = {
      desktop = {
        stylix = {
          enable = true;
          targetUsers = cfg.targetUsers;
        };
      };
    };
  };
}
