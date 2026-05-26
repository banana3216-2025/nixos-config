import Quickshell
import Quickshell.Wayland

// Define the screen panel
WaylandScreen {
    name: "main-bar"
    // Set to true to make the bar act as a dock, pushing desktop windows aside
    exclusiveZone: true 

    anchors {
        top: true
        left: true
        right: true
    }

    content: BarContent {
        color: "#282a36" // Background color
        height: 35

        Row {
            anchors.centerIn: parent
            spacing: 20

            // Text element for the clock
            Text {
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                color: "#f8f8f2"
                font.pointSize: 12

                // Timer to update the clock every second
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }
            }
        }
    }
}

