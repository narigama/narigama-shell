import QtQuick
import qs.config

// Flat single-line input.
Rectangle {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder

    signal accepted

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitWidth: 200
    implicitHeight: 32
    color: Theme.surface
    border.color: input.activeFocus ? Theme.primary : Theme.elevated
    border.width: 1

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.fg
        selectionColor: Theme.primary
        selectedTextColor: Theme.surface
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        clip: true
        onAccepted: root.accepted()
    }

    StyledText {
        anchors.fill: input
        verticalAlignment: Text.AlignVCenter
        visible: input.text === ""
        text: root.placeholder
        color: Theme.fgSubtle
    }
}
