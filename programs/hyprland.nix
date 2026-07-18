{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.hyprland;
in {
  options.custom-modules.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the hyprland window manager";
    };
    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply hyprland to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    services.dbus.enable = true;
    services.upower.enable = true;

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      config.common.default = "*";
    };

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      wayland.windowManager.hyprland = {
        enable = true;

        extraConfig = builtins.readFile (
          ../hosts + "/${config.networking.hostName}/program-data/hyprland.lua"
        );
      };
    });
  };
}
