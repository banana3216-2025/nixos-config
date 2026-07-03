import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: ram.font.pixelSize;
    property alias font_family: ram.font.family;
    property alias color: ram.color;
    property color danager_color: Config.colors.red;
    property int danager_level: 80;
    property string danager_label: "";

    property int memUsage: 0

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2; print int((t-a)/t*100)}' /proc/meminfo"]

        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    memUsage = parseInt(data.trim()) || 0;
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
        }
    }

    implicitWidth: ram.implicitWidth
    implicitHeight: ram.implicitHeight

    Text {
        id: ram

        textFormat: Text.RichText
        text: `<span style="color: ${(memUsage < danager_level) ? color : danager_color}; background-color: transparent"></span><span style="color: ${Config.colors.crust}; background-color: ${(memUsage < danager_level) ? color : danager_color}"> </span><span style="color: ${(memUsage < danager_level) ? color : danager_color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${(memUsage < danager_level) ? "" : danager_label}${String(memUsage).padStart(2, '0')}</span><span style="color: ${Config.colors.surface1}; background-color: transparent;"></span>`
    }
}
