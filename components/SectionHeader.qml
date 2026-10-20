import QtQuick
import QtQuick.Layouts
import qs.config

// Muted caption with an optional control (toggle, button) on the right.
RowLayout {
    id: root

    property string text
    default property alias trailing: trailingRow.data

    Layout.fillWidth: true
    spacing: 8

    StyledText {
        text: root.text.toUpperCase()
        color: Theme.primary
        font.pixelSize: Theme.fontSize - 2
        font.bold: true
        font.letterSpacing: 1
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.elevated
    }

    Row {
        id: trailingRow

        spacing: 8
    }
}
