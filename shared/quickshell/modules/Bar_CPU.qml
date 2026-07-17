import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: cpu.font.pixelSize;
    property alias font_family: cpu.font.family;
    property alias color: cpu.color;

    property int cpuUsage: 0
    property var cpuTracker: { "lastTotal": 0, "lastIdle": 0 }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var parts = data.trim().split(/\s+/);
                var idle = parseInt(parts[4]) + parseInt(parts[5]);
                var total = parts.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);

                if (cpuTracker.lastTotal > 0) {
                    var totalDelta = total - cpuTracker.lastTotal;
                    var idleDelta = idle - cpuTracker.lastIdle;
                    if (totalDelta > 0) {
                        cpuUsage = Math.round(100 * (1 - (idleDelta / totalDelta)));
                        console.log(cpuUsage);
                    }
                }
                cpuTracker.lastTotal = total;
                cpuTracker.lastIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
        }
    }

    implicitWidth: cpu.implicitWidth
    implicitHeight: cpu.implicitHeight

    Text {
        id: cpu

        textFormat: Text.RichText
        text: `<span style="color: ${color}; background-color: transparent"></span><span style="color: ${Config.colors.crust}; background-color: ${color}"> </span><span style="color: ${color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${String(cpuUsage).padStart(2, '0')}</span><span style="color: ${Config.colors.surface1}; background-color: transparent"></span>`
    }
}
