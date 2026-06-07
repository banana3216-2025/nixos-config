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

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      config.common.default = "*";
    };

    # Ensure systemd user session handles system-wide environment handoffs
    systemd.user.extraConfig = ''
      DefaultEnvironment="XDG_CURRENT_DESKTOP=Hyprland" "WAYLAND_DISPLAY=wayland-1"
    '';

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
