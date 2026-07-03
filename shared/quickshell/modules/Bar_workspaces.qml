import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: workspace.font.pixelSize;
    property alias font_family: workspace.font.family;
    property alias color: workspace.color;

    implicitWidth: workspace.implicitWidth
    implicitHeight: workspace.implicitHeight

    Text {
        id: workspace

        textFormat: Text.RichText
        text: `<span style="color: ${color}; background-color: transparent"></span><span style="color: ${Config.colors.crust}; background-color: ${color}; font-weight: 700;"> Workspace </span><span style="color: ${color}; background-color: ${Config.colors.surface1}; font-weight: 900;">&nbsp;#${String(Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "None").padStart(2, '0')}</span><span style="color: ${Config.colors.surface1}; background-color: transparent"></span>`
    }
}
