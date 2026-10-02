import QtQuick
import qs.config

// Flat horizontal slider over 0..1; emits moved() while dragging and released() on letting go,
// owner updates `value`. While pressed it follows the pointer, so a lagging owner can't pull it back.
Item {
    id: root

    property real value
    property color accent: Theme.primary
    property bool enabled: true
    readonly property bool dragging: mouse.pressed
    property real dragValue: 0
    readonly property real shownValue: Math.max(0, Math.min(1, dragging ? dragValue : value))

    signal moved(real value)
    signal released(real value)

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
            width: root.shownValue * parent.width
            height: parent.height
            color: root.accent
        }
    }

    Rectangle {
        x: root.shownValue * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: root.height
        color: root.accent
    }

    MouseArea {
        id: mouse

        function update(x) {
            root.dragValue = Math.max(0, Math.min(1, x / width));
            root.moved(root.dragValue);
        }

        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => update(mouse.x)
        onReleased: root.released(root.dragValue)
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
