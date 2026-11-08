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
    allow-impure-lua = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "allows a local .lua file to loaded into hyprland. Located in [user-home]/.hyprland-impure.lua";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable) {
      programs.hyprland.enable = true;
      services.dbus.enable = true;
      services.upower.enable = true;

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
      };

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          common.default = "*";
          hyprland.default = ["hyprland" "gtk"];
        };
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
            (lib.optionalString cfg.allow-impure-lua "\ndofile(\"${config.users.users.${username}.home}/.hyprland-impure.lua\")")
            (builtins.readFile (../hosts + "/${config.networking.hostName}/program-data/hyprland.lua"))
          ];
        };
      });
    })

    (lib.mkIf (cfg.enable && cfg.allow-impure-lua) {warnings = ["allow-impure-lua has been enabled in the hyprland module and will make the system impure\n consider disabling this"];})
  ];
}
