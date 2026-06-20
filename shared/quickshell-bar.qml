import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "quickshell-config.js" as Config

ShellRoot {
    property int cpuUsage: 0
    property int memUsage: 0
    property var cpuTracker: { "lastTotal": 0, "lastIdle": 0 }

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
                    }
                }
                cpuTracker.lastTotal = total;
                cpuTracker.lastIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

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
            cpuProc.running = true;
            memProc.running = true;
        }
    }

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

                height: 18
                exclusiveZone: height
                WlrLayershell.layer: WlrLayer.Top

                RowLayout {
                    anchors.fill: parent
                    spacing: 9

                    Text {
                        id: workspace

                        textFormat: Text.RichText
                        text: `<span style="color: ${Config.bar.workspace_color}; background-color: ${Config.colors.surface0}"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.bar.workspace_color}; font-weight: 700;"> Workspace </span><span style="color: ${Config.bar.workspace_color}; background-color: ${Config.colors.surface1}; font-weight: 900;">&nbsp;#${(Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "None")}</span><span style="color: ${Config.colors.surface1}; background-color: ${Config.colors.surface0}"></span>`
                        font.pixelSize: Config.font_size
                        font.family: Config.font_family
                        color: Config.colors.textcolor
                    }

                    Text {
                        id: mode

                        textFormat: Text.RichText
                        font.pixelSize: Config.font_size
                        font.family: Config.font_family
                        color: Config.colors.textcolor

                        text: `<span style="color: ${Config.bar.submapcolors[submap]}; background-color: ${Config.colors.surface0}"></span><span style="color: ${Config.colors.surface0}; background-color: ${(Config.bar.submapcolors[submap])}; font-weight: 700"> ${submap} </span><span style="color: ${Config.bar.submapcolors[submap]}; background-color: ${Config.colors.surface0};"></span>`
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        id: cpu

                        textFormat: Text.RichText
                        font.pixelSize: Config.font_size
                        font.family: Config.font_family
                        color: Config.colors.textcolor

                        text: `<span style="color: ${Config.bar.cpu_color}; background-color: ${Config.colors.surface0}"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.bar.cpu_color}"> </span><span style="color: ${Config.bar.cpu_color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${cpuUsage}</span><span style="color: ${Config.colors.surface1}; background-color: ${Config.colors.surface0}"></span>`
                    }

                    Text {
                        id: ram

                        textFormat: Text.RichText
                        font.pixelSize: Config.font_size
                        font.family: Config.font_family
                        color: Config.colors.textcolor

                        text: `<span style="color: ${(memUsage < Config.bar.ram_danager_level) ? Config.bar.ram_color : Config.bar.ram_danager_color}; background-color: ${Config.colors.surface0}"></span><span style="color: ${Config.colors.crust}; background-color: ${(memUsage < Config.bar.ram_danager_level) ? Config.bar.ram_color : Config.bar.ram_danager_color}"> </span><span style="color: ${(memUsage < Config.bar.ram_danager_level) ? Config.bar.ram_color : Config.bar.ram_danager_color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${(memUsage < Config.bar.ram_danager_level) ? "" : Config.bar.ram_danager_label}${memUsage}</span><span style="color: ${Config.colors.surface1}; background-color: ${Config.colors.surface0};"></span>`
                    }

                    Text {
                        id: clock

                        textFormat: Text.RichText
                        font.pixelSize: Config.font_size
                        font.family: Config.font_family
                        color: Config.colors.textcolor

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered: { //
                                clock.text = `<span style="color: ${Config.bar.clock_color}; background-color: ${Config.colors.surface0};"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.bar.clock_color};">󰃭 </span><span style="color: ${Config.bar.clock_color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${Qt.formatDate(new Date(), "yyyy-MM-dd")}  ${(new Date().toLocaleTimeString(Qt.locale(), "HH:mm"))}</span><span style="color: ${Config.colors.surface1}; background-color: ${Config.colors.surface0};"></span>`
                            }
                        }
                    }
                }
            }
        }
    }
}
