import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes;
import Qt.labs.folderlistmodel
import QtQuick.Effects
import Quickshell
import Quickshell.Io

ShellRoot {
    readonly property string wallpaperDir: "file://" + Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string applyScript: "/etc/nixos/shared/quickshell/quickshell-wallpaper-picker.sh"

    PanelWindow {
        id: window
        color: "#00000000"
        visible: true

        anchors.top: true;
        anchors.bottom: true;
        anchors.left: true;
        anchors.right: true;

        Keys.onEscapePressed: Qt.quit()

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height;
            color: "#60000000"

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                Text {
                    text: "Select Desktop Wallpaper"
                    color: "#cdd6f4"
                    font.pointSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                ListView {
                    id: horizontalList
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    width: window.screen.width * 1.2
                    x: window.screen.width * -0.1
                    orientation: ListView.Horizontal

                    cacheBuffer: 20000

                    property real listCenterX: contentX + (width / 2)
                    property real speed: 0;
                    property real position: 0;

                    contentX: position

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton

                        onWheel: (wheel) => {
                            let direction = (wheel.angleDelta.y > 0) ? 1 : -1;
                            horizontalList.speed += (direction * 1000);
                        }
                    }

                    FrameAnimation {
                        running: Math.abs(horizontalList.speed) > 0.01
                        onTriggered: {
                            horizontalList.position += horizontalList.speed * frameTime;
                            horizontalList.speed *= Math.pow(0.9, frameTime * 60);
                        }
                    }

                    model: FolderListModel {
                        folder: wallpaperDir
                        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
                        showDirs: false
                    }

                    delegate: Item {
                        id: delegateItem
                        height: 500

                        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

                        property real baseWidth: 500
                        property real maxExtraWidth: 300

                        property real itemCenterX: x + (baseWidth / 2)
                        property real distanceFromCenter: Math.abs((horizontalList.position + (horizontalList.width / 2) + (window.screen.width * -0.2)) - itemCenterX)
                        width: baseWidth + Math.max(0, maxExtraWidth * (1.0 - (distanceFromCenter / 400)))

                        property real relativeX: x - horizontalList.contentX

                        Rectangle {
                            anchors.fill: parent
                            color: "#313244"
                            border.color: "#cba6f7"
                            border.width: mouseArea.containsMouse ? 2 : 0

                            Image {
                                id: sourceImage
                                anchors.fill: parent
                                anchors.margins: 4
                                source: fileUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: 720
                                sourceSize.height: 480
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    applyProcess.command = ["awww", "img", filePath, "--transition-type", "random"]
                                    applyProcess.running = true
                                }
                            }
                        }
                    }
                }

            }
        }

        Process {
            id: applyProcess
            running: false
            onRunningChanged: {
                if (!running) {
                    Qt.quit()
                }
            }
        }
    }
}
