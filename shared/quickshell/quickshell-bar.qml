// This is an example usage
// if you are going to use quickshell as your bar please do not use this file

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "quickshell-config.js" as Config;
import "./modules" as Modules;

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {

            required property var modelData
            PanelWindow {
                id: barWindow
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                color: Config.colors.surface0

                implicitHeight: 18
                exclusiveZone: height
                WlrLayershell.layer: WlrLayer.Top

                RowLayout {
                    anchors.fill: parent
                    spacing: 9

                    Modules.Bar_workspaces {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        color: Config.colors.blue;
                    }

                    Modules.Bar_modes {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        submapcolors: {
                            "NORMAL": Config.colors.green,
                            "RESIZE": Config.colors.peach,
                            "MOVE": Config.colors.yellow,
                            "SESSION": Config.colors.lavender
                        };
                    }

                    Item { Layout.fillWidth: true }

                    Modules.Bar_battery {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        color: Config.colors.green;
                        charging_color: Config.colors.yellow;
                    }

                    Modules.Bar_CPU {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        color: Config.colors.sky;
                    }

                    Modules.Bar_RAM {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        color: Config.colors.blue;
                        danager_color: Config.colors.peach;
                        danager_level: 80;
                        danager_label: "!!! WARNING HIGH RAM USAGE OF ";
                    }

                    Modules.Bar_time {
                        font_size: Config.font_size;
                        font_family: Config.font_family;
                        color: Config.colors.mauve;
                        time_format: "HH:mm";
                        date_format: "yyyy-MM-dd";
                    }
                }
            }
        }
    }
}
