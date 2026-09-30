import QtQuick
import qs.config

// "-  value  +" control for small integer settings; owner updates `value` from changed().
Row {
    id: root

    property int value
    property int from: 0
    property int to: 100
    property int step: 1
    property string suffix

    signal changed(int value)

    spacing: 4

    IconButton {
        text: "-"
        implicitHeight: 24
        enabled: root.value > root.from
        onClicked: root.changed(Math.max(root.from, root.value - root.step))
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        horizontalAlignment: Text.AlignHCenter
        text: root.value + root.suffix
        font.bold: true
    }

    IconButton {
        text: "+"
        implicitHeight: 24
        enabled: root.value < root.to
        onClicked: root.changed(Math.min(root.to, root.value + root.step))
    }
}
