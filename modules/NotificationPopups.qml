import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// Notification popup stack, placed per ShellState.popupPosition; the newest sits nearest the
// screen edge. Popups slide in and out across the edge they're pinned to: sideways for left and
// right, vertically for centre.
// The surface stays mapped at a fixed size with input masked to the popups: mapping or
// resizing a layer lets the compositor fade/animate it and leaves ghosts of the old size.
PanelWindow {
    id: root

    readonly property bool atTop: ShellState.popupPosition.startsWith("top")
    readonly property bool onLeft: ShellState.popupPosition.endsWith("left")
    readonly property bool onRight: ShellState.popupPosition.endsWith("right")
    readonly property bool centred: !onLeft && !onRight
    readonly property real offscreenX: onLeft ? -width : width

    // Off-screen y (in column coordinates) for a centred card of the given height.
    function offscreenY(cardHeight) {
        return atTop ? -cardHeight - column.y : height - column.y;
    }

    // Anchored to neither side, layer-shell centres the surface horizontally.
    anchors {
        top: true
        bottom: true
        left: onLeft
        right: onRight
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

        y: root.atTop ? 0 : parent.height - height
        width: parent.width
        spacing: Config.notificationPopupGap

        // New popups slide in from the side; the rest glide to make room or close the gap.
        add: Transition {
            NumberAnimation {
                property: "x"
                from: root.centred ? 0 : root.offscreenX
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
                values: root.atTop ? Notifications.popupKeys : Notifications.popupKeys.slice().reverse()
            }

            delegate: NotificationCard {
                id: card

                required property string modelData
                readonly property bool leaving: Notifications.isLeaving(modelData)

                width: column.width
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

                // Centred cards enter from one card-height past the pinned edge (the newest is always
                // the one next to it); set once created, as the add transition runs before the
                // stack has grown.
                property bool entered: false

                Component.onCompleted: Qt.callLater(() => card.entered = true)

                // A transform, since the Column owns the card's x/y.
                transform: Translate {
                    x: card.leaving && !root.centred ? root.offscreenX : 0
                    y: {
                        if (!root.centred)
                            return 0;

                        if (card.leaving)
                            return root.offscreenY(card.height) - card.y;

                        return card.entered ? 0 : root.atTop ? -card.height : card.height;
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: Notifications.leaveMs
                            easing.type: Easing.InCubic
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 220
                            easing.type: card.leaving ? Easing.InCubic : Easing.OutCubic
                        }
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
