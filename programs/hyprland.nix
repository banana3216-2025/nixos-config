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
      description = "Users to apply hyprland and keybinds to";
    };
    useSharedKeybinds = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "switches hyprland to use the shared keybind configuration";
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
      # 1. Conditionally write the shared keybinds file directly to Home Manager
      xdg.configFile = lib.mkIf cfg.useSharedKeybinds {
        "hypr/hyprland-keybinds.lua".text = builtins.readFile ../shared/hyprland-keybinds.lua;
      };

      wayland.windowManager.hyprland = {
        enable = true;

        # 2. Append the require string conditionally inside the main configuration block
        extraConfig = lib.mkMerge [
          (lib.optionalString cfg.useSharedKeybinds "\nrequire(\"hyprland-keybinds\")\n")
          (builtins.readFile (../hosts + "/${config.networking.hostName}/program-data/hyprland.lua"))
        ];
      };
    });
  };
}
