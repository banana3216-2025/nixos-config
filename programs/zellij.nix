{
  config,
  lib,
  ...
}: let
  cfg = config.custom-modules.shell.zellij;
in {
  options.custom-modules.shell.zellij = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables the Zellij terminal multiplexer";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply zellij settings to.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      programs.zellij = {
        enable = true;

        settings = {
          theme = "catppuccin-mocha";
        };
      };
    });
  };
}
