import QtQuick
import QtQuick.Layouts
import qs.config

// Clickable row: glyph, title and subtitle, with free-form trailing content.
Rectangle {
    id: root

    property string icon
    property color iconColor: Theme.fg
    property string title
    // Overrides the title's font, e.g. to preview a font in the font picker.
    property string titleFont: Theme.fontFamily
    property string subtitle
    property bool highlighted: false
    property bool clickable: true
    default property alias trailing: trailingRow.data

    signal clicked

    Layout.fillWidth: true
    implicitHeight: Math.max(40, column.implicitHeight + 12)
    color: mouse.containsMouse && clickable ? Theme.elevated : "transparent"

    Rectangle {
        visible: root.highlighted
        width: 3
        height: parent.height
        color: Theme.primary
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 12

        StyledText {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.iconFontFamily
            color: root.iconColor
            font.pixelSize: Theme.iconSize
        }

        ColumnLayout {
            id: column

            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font.family: root.titleFont
                color: root.highlighted ? Theme.primary : Theme.fg
                font.bold: root.highlighted
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSize - 2
            }
        }

        Row {
            id: trailingRow

            spacing: 4
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.clickable)
                root.clicked();
        }
    }
}
