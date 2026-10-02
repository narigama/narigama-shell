import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.services

// After a successful unlock: a copy of the lock screen above everything that slides up off the top,
// revealing the live desktop. Always mapped at a fixed size with an empty input mask; the copy is
// only drawn while revealing.
PanelWindow {
    id: root

    required property ShellScreen targetScreen
    property real progress: 0

    screen: targetScreen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    WlrLayershell.namespace: "narigama-lock-reveal"
    WlrLayershell.layer: WlrLayer.Overlay

    Connections {
        target: Lock

        function onLockedChanged() {
            if (!Lock.locked && Lock.revealing)
                slideOut.restart();
        }
    }

    // Loaded for the whole lock, so the backdrop is ready the moment it's needed.
    Loader {
        active: Lock.locked || Lock.revealing
        visible: Lock.revealing
        width: root.width
        height: root.height
        y: -root.progress * root.height

        sourceComponent: LockBackdrop {
            screen: root.targetScreen
        }
    }

    SequentialAnimation {
        id: slideOut

        NumberAnimation {
            target: root
            property: "progress"
            from: 0
            to: 1
            duration: 380
            easing.type: Easing.InOutCubic
        }

        ScriptAction {
            script: {
                Lock.revealDone();
                root.progress = 0;
            }
        }
    }
}
