import QtQuick
import qs.config

// Flat square button holding a glyph, optionally with a text label.
Rectangle {
    id: root

    property string icon
    property string text
    property color foreground: Theme.fg
    property int iconSize: Theme.iconSize
    property bool active: false
    property bool enabled: true
    property color background: "transparent"

    signal clicked

    implicitWidth: Math.max(implicitHeight, content.implicitWidth + 16)
    implicitHeight: 32
    color: active ? Theme.primary : mouse.containsMouse && enabled ? Theme.elevated : background
    opacity: enabled ? 1 : 0.4

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 8

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.iconFontFamily
            color: root.active ? Theme.surface : root.foreground
            font.pixelSize: root.iconSize
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.active ? Theme.surface : root.foreground
            font.bold: true
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.enabled)
                root.clicked();
        }
    }
}
