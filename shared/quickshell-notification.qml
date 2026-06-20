import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

import "quickshell-config.js" as Config

Scope {
    id: root

    ListModel { id: history }
    property bool centerOpen: false

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            history.insert(0, { summary: n.summary, body: n.body, appName: n.appName, urgency: n.urgency, time: Qt.formatDateTime(new Date(), "HH:mm") })
            n.tracked = true
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle() { root.centerOpen = !root.centerOpen }
        function show() { root.centerOpen = true }
        function hide() { root.centerOpen = false }
    }

    PanelWindow {
        visible: root.screen.name == "DP-1"

        anchors {
            top: true
            left: true
        }
        margins {
            top: 12
            left: 12
        }

        implicitWidth: 380
        implicitHeight: Math.max(20, column.implicitHeight)
        color: "transparent"

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: Config.notifications.timeout
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    radius: 8
                    color: Config.colors.crust
                    border.width: 2
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Config.colors.peach : Config.colors.blue

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Config.colors.green
                                font.family: Config.font_family
                                font.pixelSize: Config.font_size
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Config.colors.textcolor
                                font.family: Config.font_family
                                font.pixelSize: Config.font_size - 2
                                wrapMode: Text.WordWrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: card.modelData.dismiss()
                        }
                    }
                }
            }
        }
    }
}
