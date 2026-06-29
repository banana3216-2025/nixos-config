import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: time.font.pixelSize;
    property alias font_family: time.font.family;
    property alias color: time.color;
    property string time_format: "";
    property string date_format: "";

    implicitWidth: time.implicitWidth
    implicitHeight: time.implicitHeight

    Text {
        id: time

        textFormat: Text.RichText
        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                parent.text = `<span style="color: ${color}; background-color: ${Config.colors.surface0};"></span><span style="color: ${Config.colors.crust}; background-color: ${color};">󰃭 </span><span style="color: ${color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${Qt.formatDate(new Date(), date_format)}  ${(new Date().toLocaleTimeString(Qt.locale(), time_format))}</span><span style="color: ${Config.colors.surface1}; background-color: ${Config.colors.surface0};"></span>`
            }
        }
    }
}
