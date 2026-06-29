import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: mode.font.pixelSize;
    property alias font_family: mode.font.family;

    property string submap: "NORMAL"

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "submap") {
                let name = event.data.trim();

                if (name === "") {
                    submap = "NORMAL";
                } else {
                    submap = name.toUpperCase();
                }
            }
        }
    }
    property var submapcolors: {
        "NORMAL": Config.colors.green,
        "RESIZE": Config.colors.peach,
        "MOVE": Config.colors.yellow,
        "SESSION": Config.colors.lavender
    };

    implicitWidth: mode.implicitWidth
    implicitHeight: mode.implicitHeight

    Text {
        id: mode

        textFormat: Text.RichText
        text: `<span style="color: ${submapcolors[submap]}; background-color: ${Config.colors.surface0}"></span><span style="color: ${Config.colors.surface0}; background-color: ${(submapcolors[submap])}; font-weight: 700"> ${submap} </span><span style="color: ${submapcolors[submap]}; background-color: ${Config.colors.surface0};"></span>`
    }
}
