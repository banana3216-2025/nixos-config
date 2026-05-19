{
  config,
  lib,
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

    targetUsers = {
      type = lib.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply hyprland to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          #monitor = [ ",1920x1080@60hz,auto,1" ];

          # 1. Variables (Nix variables for reuse)
          "$mainMod" = "SUPER";
          "$terminal" = "kitty";
          # "$menu" = "wofi --show drun";

          exec-once = [
            "dbus-update-activation-environment --systemd --all"
            #"$BAR"
            #"$WALLPAPER"
            "hyprctl setcursor Bibata-Modern-Classic 24"
            "gsettings set org.gnome.desktop.interface cursor-size 24"
            "gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'"
            # Execute configuration setters on Hyprland launch
            "exec-once = gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
            "exec-once = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"

            # Set environment variables for the compositor pipeline
            "env = XDG_CURRENT_DESKTOP,Hyprland"
            "env = XDG_SESSION_TYPE,wayland"
            "env = XDG_SESSION_DESKTOP,Hyprland"
          ];

          # 4. Input Configuration
          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad = {
              natural_scroll = false;
            };
            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          };

          # 5. General Layout & Appearance
          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";
            layout = "dwindle";
            allow_tearing = false;
          };

          # 6. Decoration (Blur, Opacity, Shadows)
          decoration = {
            rounding = 10;
            active_opacity = 1.0;
            inactive_opacity = 0.9;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          # 7. Animations
          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          # 8. Layout Specifics
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          # 10. Window Rules (v1 or v2)
          windowrulev2 = [
            "opacity 0.8 0.8,class:^(kitty)$"
            "animation popin,class:^(kitty)$,title:^(update)$"
            "float,class:^(pavucontrol)$"
          ];

          # 11. Keybinds
          bind = [
            "$mainMod, Q, exec, $terminal"
            "$mainMod, W, killactive,"
            "$mainMod, M, exit,"
            "$mainMod, E, exec, $fileManager"
            "$mainMod, V, togglefloating,"
            "$mainMod, space, exec, $LAUNCHER"
            "$mainMod, P, pseudo," # dwindle
            "$mainMod, J, togglesplit," # dwindle

            # Focus Movement
            "$mainMod, h, movefocus, l"
            "$mainMod, l, movefocus, r"
            "$mainMod, k, movefocus, u"
            "$mainMod, j, movefocus, d"

            # Window Movement
            "$mainMod SHIFT, H, movewindow, l"
            "$mainMod SHIFT, L, movewindow, r"
            "$mainMod SHIFT, K, movewindow, u"
            "$mainMod SHIFT, J, movewindow, d"

            # Workspace Switching (1-10)
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # Move active window to workspace
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"
          ];

          # Mouse Binds (m prefix)
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
      };
    });
  };
}
