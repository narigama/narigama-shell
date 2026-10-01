import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 340
    spacing: 12

    // Picks up changes made elsewhere (monitor buttons, other tools).
    Component.onCompleted: Desk.refresh()

    StyledText {
        visible: Desk.displays.length === 0
        text: "No DDC/CI displays found"
        color: Theme.fgMuted
    }

    Repeater {
        model: Desk.displays

        delegate: ColumnLayout {
            id: display

            required property var modelData
            readonly property int level: Desk.brightness[modelData.bus] ?? 0

            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: display.modelData.screen + (display.modelData.model ? "  " + display.modelData.model : "")
                }

                StyledText {
                    text: display.level + "%"
                    color: Theme.yellow
                    font.bold: true
                }
            }

            Slider {
                Layout.fillWidth: true
                value: display.level / 100
                accent: Theme.yellow
                onMoved: value => Desk.setBrightness(display.modelData.bus, value * 100)
            }
        }
    }
}
