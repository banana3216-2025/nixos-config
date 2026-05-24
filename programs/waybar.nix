{
  config,
  lib,
  ...
}: let
  cfg = config.custom-modules.desktop.waybar;
in {
  options.custom-modules.desktop.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable waybar";
    };
    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to add waybar to (you really should just add to the main user)";
    };
    autoStartup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add waybar to startup";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.users = lib.genAttrs cfg.targetUsers (username: {
        programs.waybar = {
          enable = true;
          style = ''
            * {
              border: none;
              border-radius: 0;
              font-family: "JetBrainsMono NF", "Symbols Nerd Font", sans-serif;
              font-size: 12px;
              min-height: 0;
            }
            window#waybar {
              background: none;
              padding-top: 5px;
              color: #a678d3;
              transition-property: background-color;
              transition-duration: .5s;
            }
            window#waybar.hidden {
              opacity: 0.2;
            }
            #workspaces button {
              padding-left: 10px;
              padding-right: 10px;
              background-color: transparent;
              color: inherit;
              font-weight: 600;
              border-top: 4px solid transparent;
              border-bottom: 3px solid transparent;
              border-left: 2px dashed #a678d3;
            }
            #workspaces button:first-child {
              border-left: 0;
            }
            #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
              box-shadow: inherit;
              text-shadow: inherit;
              border-bottom: 3px solid #a678d3;
              border-top: 3px solid #a678d3;
            }
            #workspaces button.focused {
              background: rgba(0, 0, 0, 0.2);
              border-top: 3px solid #9730fd;
              border-bottom: 3px solid #9730fd;
              border-left: 2px dashed #9730fd;
              border-right: 2px dashed #9730fd;
              color: #9730fd;
            }
            #workspaces button.focused + button {
              border-left: none;
            }
            #workspaces button.focused:first-child {
              border-left: none;
            }
            #workspaces button.focused:last-child {
              border-right: none;
            }
            #workspaces button.urgent {
              background-color: #eb4d4b;
            }
            #mpd, #pulseaudio, #network, #cpu, #memory, #temperature, #clock, #window {
              padding-left: 8px;
              padding-right: 8px;
              background-color: transparent;
              color: inherit;
              font-weight: 600;
              border-top: 4px solid transparent;
              border-bottom: 3px solid transparent;
              border-left: 2px dashed #a678d3;
            }
            #tray {
              margin: 10px;

              padding-left: 8px;
              padding-right: 8px;
              min-width: 20px;
              border-left: 2px dashed #a678d3;
              font-size: 20px;
            }
            #window {
              min-width: 500px;
            }
            #clock {
              font-size: 14px;
            }
            #mpd.playing {
              background: repeating-linear-gradient(
                45deg, #453e48, #453e48 12px, #3d3540 12px, #3d3540 24px
              );
              background-size: 120% 100%;
              animation: scroll 0.5s linear infinite;
            }
            @keyframes scroll {
              from { background-position: -33.941125497px 0; }
              to { background-position: 0 0; }
            }
          '';
          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              height = 32;
              modules-left = ["hyprland/workspaces"];
              modules-center = ["clock"];
              modules-right = ["network" "battery" "cpu" "memory" "tray"];
              "hyprland/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
              };
              clock = {
                format = "{:%H:%M}";
                tooltip-format = "{:%A, %d %B %Y}";
              };
              network = {
                format-wifi = "Strength: {signalStrength}%";
                format-ethernet = "Connected";
                format-disconnected = "Offline";
              };
              battery = {
                format = "{capacity}%";
                format-charging = "Charging; {capacity}%";
                format-full = "Full; {capacity}%";
              };
              cpu = {
                format = "CPU: {usage}%";
              };
              memory = {
                format = " {used}GB";
              };
              tray = {
                spacing = 10;
              };
            };
          };
        };
      });
    })
    (lib.mkIf cfg.autoStartup {
      # You can populate this later depending on your Display Manager or Compositor
    })
  ];
}
