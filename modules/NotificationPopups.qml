import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// Bottom-right popup stack.
// The surface stays mapped at a fixed size with input masked to the popups: mapping or
// resizing a layer lets the compositor fade/animate it and leaves ghosts of the old size.
PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        right: true
    }
    implicitWidth: 400
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    mask: Region {
        item: column
    }

    WlrLayershell.namespace: "narigama-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
        id: column

        anchors.bottom: parent.bottom
        width: parent.width
        spacing: Config.notificationPopupGap

        // New popups slide in from the right; the rest glide to make room or close the gap.
        add: Transition {
            NumberAnimation {
                property: "x"
                from: column.width
                to: 0
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        move: Transition {
            NumberAnimation {
                property: "y"
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            // Diffed rather than replaced, so existing cards (and their countdowns) survive
            // other popups arriving or leaving.
            model: ScriptModel {
                values: Notifications.popupKeys
            }

            delegate: NotificationCard {
                id: card

                required property string modelData
                readonly property bool leaving: Notifications.isLeaving(modelData)

                width: column.width
                x: leaving ? column.width : 0
                // Closing a popup removes its history entry at once; keep showing it while it slides out.
                property var lastEntry: null
                entry: Notifications.entry(modelData) ?? lastEntry ?? {
                    "key": modelData,
                    "summary": "",
                    "body": "",
                    "actions": [],
                    "time": Date.now()
                }

                onEntryChanged: lastEntry = entry

                Behavior on x {
                    enabled: card.leaving

                    NumberAnimation {
                        duration: Notifications.leaveMs
                        easing.type: Easing.InCubic
                    }
                }

                // Critical notifications stay until dismissed; hovering pauses the countdown.
                Timer {
                    interval: ShellState.popupSeconds * 1000
                    running: !card.critical && !card.hovered && !card.leaving
                    onTriggered: Notifications.hidePopup(card.modelData)
                }
            }
        }
    }
}
