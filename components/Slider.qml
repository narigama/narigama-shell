import QtQuick
import qs.config

// Flat horizontal slider over 0..1; emits moved() while dragging, owner updates `value`.
Item {
    id: root

    property real value
    property color accent: Theme.primary
    property bool enabled: true
    readonly property bool dragging: mouse.pressed

    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 16
    opacity: enabled ? 1 : 0.4

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        color: Theme.elevated

        Rectangle {
            width: Math.max(0, Math.min(1, root.value)) * parent.width
            height: parent.height
            color: root.accent
        }
    }

    Rectangle {
        x: Math.max(0, Math.min(1, root.value)) * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: root.height
        color: root.accent
    }

    MouseArea {
        id: mouse

        function update(x) {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }

        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => update(mouse.x)
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
