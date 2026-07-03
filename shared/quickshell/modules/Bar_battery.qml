import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower

import "../quickshell-config.js" as Config;

Item {
    property alias font_size: battery.font.pixelSize;
    property alias font_family: battery.font.family;
    property alias color: battery.color;
    property color charging_color: Config.colors.yellow;

    property var mainBattery: UPower.displayDevice;

    implicitWidth: battery.implicitWidth
    implicitHeight: battery.implicitHeight

    Text {
        id: battery

        textFormat: Text.RichText
        text: `<span style="color: ${(mainBattery.state == UPowerDeviceState.Charging) ? charging_color : color}; background-color: transparent"></span><span style="color: ${Config.colors.crust}; background-color: ${(mainBattery.state == UPowerDeviceState.Charging) ? charging_color : color}">${(mainBattery.state == UPowerDeviceState.Charging) ? " " : "󰄌 "}</span><span style="color: ${(mainBattery.state == UPowerDeviceState.Charging) ? charging_color : color}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;${String(mainBattery.percentage * 100).padStart(2, '0')}</span><span style="color: ${Config.colors.surface1}; background-color: transparent"></span>`
    }
}
