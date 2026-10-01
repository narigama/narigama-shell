import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 300
    spacing: 8

    SectionHeader {
        text: "Recent colours"
    }

    StyledText {
        visible: Capture.pickedColors.length === 0
        text: "Left click the picker to grab a colour"
        color: Theme.fgMuted
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: Capture.pickedColors

            delegate: Rectangle {
                required property string modelData

                Layout.fillWidth: true
                implicitHeight: 32
                color: swatchMouse.containsMouse ? Theme.elevated : Theme.surface

                Rectangle {
                    id: chip

                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 20
                    color: parent.modelData
                    border.color: Theme.elevated
                }

                StyledText {
                    anchors.left: chip.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.modelData
                }

                MouseArea {
                    id: swatchMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Capture.copyColor(parent.modelData)
                }
            }
        }
    }
}
