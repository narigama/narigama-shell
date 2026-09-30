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
        Layout.fillWidth: true
        text: root.text.toUpperCase()
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSize - 2
        font.bold: true
        font.letterSpacing: 1
    }

    Row {
        id: trailingRow

        spacing: 8
    }
}
