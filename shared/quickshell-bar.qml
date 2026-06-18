import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    readonly property color rosewater: "#f5e0dc" 
    readonly property color flamingo:  "#f2cdcd" 
    readonly property color pink:      "#f5c2e7" 
    readonly property color mauve:     "#cba6f7" 
    readonly property color red:       "#f38ba8" 
    readonly property color maroon:    "#eba0ac" 
    readonly property color peach:     "#fab387" 
    readonly property color yellow:    "#f9e2af" 
    readonly property color green:     "#a6e3a1" 
    readonly property color teal:      "#94e2d5" 
    readonly property color sky:       "#89dceb" 
    readonly property color sapphire:  "#74c7ec" 
    readonly property color blue:      "#89b4fa" 
    readonly property color lavender:  "#b4befe" 
    readonly property color textcolor: "#cdd6f4" 
    readonly property color subtext1:  "#bac2de" 
    readonly property color subtext0:  "#a6adc8" 
    readonly property color overlay2:  "#9399b2" 
    readonly property color overlay1:  "#7f849c" 
    readonly property color overlay0:  "#6c7086" 
    readonly property color surface2:  "#585b70" 
    readonly property color surface1:  "#45475a" 
    readonly property color surface0:  "#313244" 
    readonly property color base:      "#1e1e2e" 
    readonly property color mantle:    "#181825" 
    readonly property color crust:     "#11111b" 

    readonly property int   font_size:         15

    readonly property color workspace_color:   blue
    readonly property color cpu_color:         red
    readonly property color ram_color:         lavender
    readonly property color ram_danager_color: peach
    readonly property color clock_color:       mauve

    readonly property int    ram_danager_level: 85
    readonly property string ram_danger_label:  "!!! DANGER RAM USAGE APPROCHING A LEVEL WHERE THE SYSTEM WILL BEGIN TO CLOSE PROGRAMS !!! usage: "

    property string submap: "NORMAL"

    readonly property var submapcolors: ({
        "NORMAL":      green, 
        "RESIZE":      peach,
        "MOVE":        yellow,
        "SESSION":     lavender
    })
    
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

    property int cpuUsage: 0
    property int memUsage: 0
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

                  color: surface0

                  height: 18
                  exclusiveZone: height 
                  WlrLayershell.layer: WlrLayer.Top
 

                  RowLayout { 
                      anchors.fill: parent
                      spacing: 9

                      Text {
                          id: workspace

                          textFormat: Text.RichText
                          text: `<span style="color: ${workspace_color}; background-color: ${surface0}"></span><span style="color: ${crust}; background-color: ${workspace_color}; font-weight: 700;"> Workspace </span><span style="color: ${workspace_color}; background-color: ${surface1}; font-weight: 900;">&nbsp;#${(Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "None")}</span><span style="color: ${surface1}; background-color: ${surface0}"></span>`
                          font.pixelSize: font_size
                          font.family: "JetBrainsMono Nerd Font"
                          color: textcolor
                      }

                      Text {
                          id: mode

                          textFormat: Text.RichText
                          font.pixelSize: font_size
                          font.family: "JetBrainsMono Nerd Font"
                          color: textcolor

                          text: `<span style="color: ${submapcolors[submap]}; background-color: ${surface0}"></span><span style="color: ${surface0}; background-color: ${(submapcolors[submap])}; font-weight: 700"> ${submap} </span><span style="color: ${submapcolors[submap]}; background-color: ${surface0};"></span>`
                      }

                      Item { Layout.fillWidth: true }

                      Text {
                          id: cpu

                          textFormat: Text.RichText
                          font.pixelSize: font_size
                          font.family: "JetBrainsMono Nerd Font"
                          color: textcolor

                          text: `<span style="color: ${cpu_color}; background-color: ${surface0}"></span><span style="color: ${crust}; background-color: ${cpu_color}"> </span><span style="color: ${cpu_color}; background-color: ${surface1}; font-weight: 700;">&nbsp;${cpuUsage}</span><span style="color: ${surface1}; background-color: ${surface0}"></span>`
                      }

                      Text {
                          id: ram

                          textFormat: Text.RichText
                          font.pixelSize: font_size
                          font.family: "JetBrainsMono Nerd Font"
                          color: textcolor

                          text: `<span style="color: ${(memUsage < ram_danager_level) ? ram_color : ram_danager_color}; background-color: ${surface0}"></span><span style="color: ${crust}; background-color: ${(memUsage < ram_danager_level) ? ram_color : ram_danager_color}"> </span><span style="color: ${(memUsage < ram_danager_level) ? ram_color : ram_danager_color}; background-color: ${surface1}; font-weight: 700;">&nbsp;${(memUsage < ram_danager_level) ? "" : ram_danger_label}${memUsage}</span><span style="color: ${surface1}; background-color: ${surface0};"></span>`
                      }

                      Text {
                          id: clock

                          textFormat: Text.RichText
                          font.pixelSize: font_size
                          font.family: "JetBrainsMono Nerd Font"
                          color: textcolor

                          Timer {
                              interval: 1000
                              running: true
                              repeat: true
                              triggeredOnStart: true
                              onTriggered: { // 
                                  clock.text = `<span style="color: ${clock_color}; background-color: ${surface0};"></span><span style="color: ${crust}; background-color: ${clock_color};">󰃭 </span><span style="color: ${clock_color}; background-color: ${surface1}; font-weight: 700;">&nbsp;${Qt.formatDate(new Date(), "yyyy-MM-dd")}  ${(new Date().toLocaleTimeString(Qt.locale(), "HH:mm"))}</span><span style="color: ${surface1}; background-color: ${surface0};"></span>`
                              }
                          }
                      }
                  }
              }
         }
    }
}
