import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

import "quickshell-config.js" as Config

ShellRoot {
    id: root

    ListModel { id: history }
    property bool centerOpen: false

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            history.insert(0, {
                    summary: n.summary,
                    body: n.body,
                    appName: n.appName,
                    image: n.image,
                    urgency: n.urgency,
                    time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            n.tracked = true
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle() { root.centerOpen = !root.centerOpen }
        function open() { root.centerOpen = true }
        function close() { root.centerOpen = false }
    }

    function findScreenByName(name) {
        for (var i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === name) {
                return Quickshell.screens[i];
            }
        }
        return Quickshell.screens[0];
    }

    PanelWindow {
        screen: findScreenByName("DP-1")

        anchors {
            top: true
            left: true
        }

        implicitWidth: 400
        implicitHeight: Math.max(20, column.implicitHeight)
        color: "transparent"

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    required property var modelData
                    id: card;

                    width: parent.width;
                    height: card_information.implicitHeight;

                    color: Config.colors.surface1;

                    Timer {
                        running: modelData.urgency !== NotificationUrgency.Critical;
                        interval: 5000;
                        onTriggered: card.modelData.dismiss();
                    }

                    ColumnLayout {
                        id: card_information;
                        width: parent.width;
                        spacing: 0;

                        Rectangle {
                            width: parent.width;
                            height: topbar.height;

                            color: Config.colors.surface0;

                            RowLayout {
                                width: parent.width;
                                id: topbar;

                                Text {
                                    Layout.fillWidth: true;

                                    textFormat: Text.RichText
                                    color: Config.colors.green;
                                    font.family: Config.font_family;
                                    font.pixelSize: Config.font_size;

                                    text: `<span style="color: ${modelData.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green};"></span><span style="color: ${Config.colors.crust}; background-color: ${modelData.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green};">󰍡 </span><span style="color: ${modelData.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green}; background-color: ${Config.colors.surface2};">&nbsp;${modelData.summary}</span><span style="color: ${Config.colors.surface2};"></span>`;
                                }

                                Text {
                                    textFormat: Text.RichText
                                    color: Config.colors.red;
                                    font.family: Config.font_family;
                                    font.pixelSize: Config.font_size;

                                    text: `<span style="color: ${Config.colors.red};"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.colors.red};"></span><span style="color: ${Config.colors.red};"></span>`;

                                    MouseArea {
                                        anchors.fill: parent;
                                        onClicked: card.modelData.dismiss();
                                    }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 0

                            Text {
                                id: body

                                Layout.fillWidth: true;

                                visible: modelData.body !== "";
                                wrapMode: Text.WordWrap;

                                color: Config.colors.textcolor;
                                font.family: Config.font_family;
                                font.pixelSize: Config.font_size;

                                text: modelData.body;
                            }

                            Image {
                                id: image;

                                Layout.preferredHeight: Math.max(32, Math.min(body.height, 64));
                                Layout.preferredWidth: Math.max(32, Math.min(body.height, 64));
                                Layout.alignment: Qt.AlignTop;

                                fillMode: Image.PreserveAspectFit
                                source: (modelData.image && modelData.image !== "") ? modelData.image : ((modelData.appIcon && model.appIcon !== "") ? modelData.appIcon : "")
                            }
                        }
                    }
                }
            }
        }
    }
    PanelWindow {
        screen: findScreenByName("DP-1");

        anchors.left: true;
        anchors.top: true;
        anchors.bottom: true;
        implicitWidth: root.centerOpen * 500;

        color: "transparent";

        Rectangle {
            id: notification_center;
            anchors.fill: parent

            color: Config.colors.surface0;

            ColumnLayout {
                anchors.fill: parent;
                spacing: 0;

                Text {
                    textFormat: Text.RichText;

                    font.pixelSize: Config.font_size;
                    font.family: Config.font_family;

                    text: `<span style="color: ${Config.colors.blue}; background-color: transparent"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.colors.blue}"> </span><span style="color: ${Config.colors.textcolor}; background-color: ${Config.colors.surface1}; font-weight: 700;">&nbsp;Notifications Center</span><span style="color: ${Config.colors.surface1}; background-color: transparent"></span>`;
                }

                ColumnLayout {
                    spacing: 0;

                    Text {
                        visible: history.count == 0;

                        Layout.fillWidth: true;
                        Layout.fillHeight: true;

                        textFormat: Text.RichText;

                        font.pixelSize: Config.font_size;
                        font.family: Config.font_family;
                        color: Config.colors.textcolor;

                        text: "No notifications Found"
                    }

                    Text {
                        visible: history.count > 0;

                        textFormat: Text.RichText;

                        font.pixelSize: Config.font_size;
                        font.family: Config.font_family;
                        color: Config.colors.textcolor;

                        text: "Hey look you have some notifications."
                    }

                    RowLayout {
                        spacing: Config.font_size * 0.5

                        Text {
                            visible: history.count > 0;

                            textFormat: Text.RichText;

                            font.pixelSize: Config.font_size;
                            font.family: Config.font_family;
                            color: Config.colors.textcolor;

                            text: "Do you want to clear them."
                        }

                        Text {
                            visible: history.count > 0;

                            textFormat: Text.RichText;

                            font.pixelSize: Config.font_size;
                            font.family: Config.font_family;
                            color: Config.colors.red;

                            text: "<b>Yes</b>"

                            MouseArea {
                                anchors.fill: parent;
                                onClicked: history.clear();
                            }
                        }

                    }
                }

                ListView {
                    id: history_view

                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: history;
                    //spacing: Config.font_size;
                    spacing: 0;

                    delegate: Rectangle {
                        id: card;

                        width: notification_center.width;
                        height: card_information.implicitHeight;

                        color: Config.colors.surface1;

                        ColumnLayout {
                            id: card_information;
                            width: parent.width;
                            spacing: 0;

                            Rectangle {
                                width: parent.width;
                                height: topbar.height;

                                color: Config.colors.surface0;

                                RowLayout {
                                    width: parent.width;
                                    id: topbar;

                                    Text {
                                        textFormat: Text.RichText
                                        color: Config.colors.green;
                                        font.family: Config.font_family;
                                        font.pixelSize: Config.font_size;

                                        text: `<span style="color: ${model.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green};"></span><span style="color: ${Config.colors.crust}; background-color: ${model.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green};">󰍡 </span><span style="color: ${model.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.green}; background-color: ${Config.colors.surface2};">&nbsp;${model.summary}</span><span style="color: ${Config.colors.surface2};"></span>`;
                                    }

                                    Item {
                                        Layout.fillWidth: true;
                                    }

                                    Text {
                                        textFormat: Text.RichText
                                        color: Config.colors.red;
                                        font.family: Config.font_family;
                                        font.pixelSize: Config.font_size;

                                        text: `<span style="color: ${Config.colors.red};"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.colors.red};"></span><span style="color: ${Config.colors.red};"></span>`;

                                        MouseArea {
                                            anchors.fill: parent;
                                            onClicked: history.remove(index);
                                        }
                                    }

                                    Text {
                                        textFormat: Text.RichText
                                        color: Config.colors.lavender;
                                        font.family: Config.font_family;
                                        font.pixelSize: Config.font_size;

                                        text: `<span style="color: ${Config.colors.lavender};"></span><span style="color: ${Config.colors.crust}; background-color: ${Config.colors.lavender};"> </span><span style="color: ${Config.colors.lavender}; background-color: ${Config.colors.surface2};">&nbsp;${model.time}</span><span style="color: ${Config.colors.surface2};"></span>`;
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 0

                                Text {
                                    id: body

                                    Layout.fillWidth: true;

                                    visible: model.body !== "";
                                    wrapMode: Text.WordWrap;

                                    color: Config.colors.textcolor;
                                    font.family: Config.font_family;
                                    font.pixelSize: Config.font_size;

                                    text: model.body;
                                }

                                Image {
                                    id: image;

                                    Layout.preferredHeight: Math.max(32, Math.min(body.height, 64));
                                    Layout.preferredWidth: Math.max(32, Math.min(body.height, 64));
                                    Layout.alignment: Qt.AlignTop;

                                    fillMode: Image.PreserveAspectFit
                                    source: (model.image && model.image !== "") ? model.image : ((model.appIcon && model.appIcon !== "") ? model.appIcon : "")
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}
