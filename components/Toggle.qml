import QtQuick
import qs.config

// Flat on/off switch; emits toggled() and leaves updating `checked` to the owner.
Item {
    id: root

    property bool checked
    property color accent: Theme.primary

    signal toggled

    implicitWidth: 36
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        color: root.checked ? root.accent : Theme.elevated

        Rectangle {
            x: root.checked ? parent.width - width - 3 : 3
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - 6
            height: width
            color: root.checked ? Theme.surface : Theme.fgMuted

            Behavior on x {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
