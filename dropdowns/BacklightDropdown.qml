import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 340
    spacing: 12
    // Picks up changes made elsewhere (firmware keys, power profiles dimming the screen).
    Component.onCompleted: Backlight.refresh()

    StyledText {
        visible: !Tools.available("backlight")
        Layout.fillWidth: true
        text: Tools.hint("backlight")
        color: Theme.yellow
        wrapMode: Text.Wrap
    }

    StyledText {
        visible: Tools.available("backlight") && Backlight.screen === null && Backlight.keyboard === null
        text: "No backlight found"
        color: Theme.fgMuted
    }

    Level {
        visible: Backlight.screen !== null
        label: "Screen"
        fraction: Backlight.screenFraction
        onMoved: (value) => {
            return Backlight.setScreen(value);
        }
    }

    Level {
        visible: Backlight.keyboard !== null
        label: "Keyboard"
        fraction: Backlight.keyboardFraction
        onMoved: (value) => {
            return Backlight.setKeyboard(value * Backlight.keyboard.max);
        }
    }

    component Level: ColumnLayout {
        id: level

        property string label
        property real fraction

        signal moved(real value)

        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true
                text: level.label
            }

            StyledText {
                text: Math.round(level.fraction * 100) + "%"
                color: Theme.yellow
                font.bold: true
            }

        }

        Slider {
            Layout.fillWidth: true
            value: level.fraction
            accent: Theme.yellow
            onMoved: (value) => {
                return level.moved(value);
            }
        }

    }

}
