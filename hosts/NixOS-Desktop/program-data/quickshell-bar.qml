import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    // --- FIXED STATE VARIABLES AND SCOPE TRACKERS ---
    property int cpuUsage: 0
    property int memUsage: 0
    property var cpuTracker: { "lastTotal": 0, "lastIdle": 0 }

    Scope {
        PanelWindow {
            id: barWindow
            screen: null
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            height: 45
            exclusiveZone: height 
            WlrLayershell.layer: WlrLayer.Top
            color: "transparent"

            // --- DATA SAMPLING ENGINES ---
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

            // Main Background Container
            Rectangle {
                anchors.fill: parent
                color: "#001e1e2e" // Fully transparent base backing

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    // === LEFT MODULE: WORKSPACE SWITCHER ===
                    WrapperRectangle {
                        border.width: 0
                        border.color: "#24273a"
                        color: "#24273a"
                        radius: 8
                        margin: 8

                        RowLayout {
                            spacing: 8
                            Layout.margins: 6 // Padding inside the widget container

                            Repeater {
                                model: [1, 2, 3, 4, 5, 6, 7, 8]

                                delegate: Rectangle {
                                    id: workspaceButton
                                    width: 24
                                    height: 24
                                    radius: 4
                                    
                                    readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData

                                    color: isFocused ? "#89b4fa" : "transparent"
                                    border.color: isFocused ? "transparent" : "#5b6078"
                                    border.width: 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 12
                                        font.bold: workspaceButton.isFocused
                                        color: workspaceButton.isFocused ? "#11111b" : "#cdd6f4"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var targetWs = Hyprland.workspaces.values.find(function(ws) {
                                                return ws.id === modelData;
                                            });

                                            if (targetWs) {
                                                targetWs.activate();
                                            } else {
                                                Hyprland.dispatch("hl.dispatch('workspace', '" + modelData + "')");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // === CENTER MODULE: CLOCK ===
                    WrapperRectangle {
                        border.width: 0
                        border.color: "#24273a"
                        color: "#24273a"
                        radius: 8
                        margin: 8

                        Text {
                            id: clockText
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            anchors.centerIn: parent

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                triggeredOnStart: true
                                onTriggered: {
                                    clockText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss AP")
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // === RIGHT MODULE: CPU & MEMORY METRICS ===
                    WrapperRectangle {
                        border.width: 0
                        border.color: "#24273a"
                        color: "#24273a"
                        radius: 8
                        margin: 8

                        RowLayout {
                            spacing: 15
                            Layout.margins: 6 // Padding inside the widget container

                            // CPU Sub-Widget
                            RowLayout {
                                spacing: 6
                                Text { 
                                    text: "" 
                                    color: "#f38ba8" 
                                    font.pixelSize: 14 
                                }
                                Text { 
                                    text: cpuUsage + "%"
                                    color: "#cdd6f4"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }

                            // Memory Sub-Widget
                            RowLayout {
                                spacing: 6
                                Text { 
                                    text: "" 
                                    color: "#fab387" 
                                    font.pixelSize: 14 
                                }
                                Text { 
                                    text: memUsage + "%"
                                    color: "#cdd6f4"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
