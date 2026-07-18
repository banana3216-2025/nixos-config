import Quickshell
import Quickshell.Widgets
import QtQuick
import Qt.labs.folderlistmodel 2.15
import Quickshell.Io

ShellRoot {
    Process {
        id: wallpaperSetter
    }

    PanelWindow {
        id: window
        width: 800
        height: 600

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            radius: 12

            FolderListModel {
                id: folderModel
                folder: "file:///home/a/Pictures/Wallpapers"
                nameFilters: ["*.png", "*.jpg", "*.jpeg"]
            }

            GridView {
                anchors.fill: parent
                anchors.margins: 20
                model: folderModel
                cellWidth: 200
                cellHeight: 200

                delegate: Rectangle {
                    width: 180
                    height: 180
                    radius: 8
                    color: "#11111b"

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 200
                        sourceSize.height: 200

                        asynchronous: true
                        cache: true

                        source: (typeof fileUrl !== "undefined" && fileUrl) ? fileUrl : ""
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        // Add a slight hover effect so you know it's clickable
                        onEntered: parent.border.color = "#cba6f7"
                        onExited: parent.border.color = "transparent"

                        onClicked: {
                            if (typeof fileUrl !== "undefined" && fileUrl) {
                                // Strip the 'file://' prefix if swww fails to read standard URIs
                                let cleanPath = fileUrl.toString().replace("file://", "");

                                wallpaperSetter.exec(["awww", "img", cleanPath]);
                            }
                        }
                    }
                }
            }
        }
    }
}
