import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// Bottom-centre OSD pill on the focused monitor. Always mapped at a fixed size with an empty
// input mask (it never takes clicks), so the compositor has nothing to fade or resize.
PanelWindow {
    id: root

    required property ShellScreen targetScreen
    readonly property bool active: Osd.shown && Hyprland.focusedMonitor?.name === targetScreen.name
    readonly property int bottomGap: 64

    screen: targetScreen
    anchors.bottom: true
    implicitWidth: 380
    implicitHeight: pill.height + bottomGap
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    WlrLayershell.namespace: "narigama-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.active ? 0 : root.height
        width: parent.width
        height: 56
        color: Theme.bg
        border.color: Theme.elevated
        border.width: 1

        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            StyledText {
                text: Osd.icon
                color: Osd.accent
                font.family: Theme.iconFontFamily
                font.pixelSize: 26
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    Layout.fillWidth: true
                    text: Osd.label
                    font.bold: true
                }

                Meter {
                    Layout.fillWidth: true
                    visible: Osd.value >= 0
                    value: Osd.value
                    accent: Osd.accent
                }
            }
        }
    }
}
