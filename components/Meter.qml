import QtQuick
import qs.config

// Thin horizontal usage bar over 0..1.
Rectangle {
    property real value
    property color accent: Theme.primary

    implicitWidth: 100
    implicitHeight: 4
    color: Theme.elevated

    Rectangle {
        width: Math.max(0, Math.min(1, parent.value)) * parent.width
        height: parent.height
        color: parent.accent
    }
}
