import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Services.Notifications

ShellRoot {
    NotificationServer {
        id: notifyServer
        
        // Advertise required capabilities to the system
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        
        // trackedNotifications holds the active list model automatically
    }

    ListView {
        width: 350
        height: 400
        model: notifyServer.trackedNotifications
        spacing: 8

        delegate: Rectangle {
            width: parent.width
            height: 60
            color: "#2a2a2a"
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                // Display application icon if available
                Image {
                    source: modelData.appIcon ? "image://icon/" + modelData.appIcon : ""
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Column {
                    Text { text: modelData.summary; color: "white"; font.bold: true }
                    Text { text: modelData.body; color: "gray" }
                }
                
                // Close button to dismiss individual notification
                Button {
                    text: "X"
                    onClicked: modelData.dismiss()
                }
            }
        }
    }
}
