import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// One screen of the lock: the wallpaper, lightly blurred, with a large clock top-left and the
// password row along the bottom edge. The row slides up when typing starts and back down after a
// quiet spell. Text is light on dark gradients rather than themed, since it sits on the wallpaper.
WlSessionLockSurface {
    id: root

    readonly property color ink: "#f4f1ec"
    readonly property color inkMuted: "#b8b2aa"
    readonly property int margin: 72
    // The row stays up while there's something typed, a check running or a message to read.
    readonly property bool rowShown: active || Lock.password !== "" || Lock.authenticating || Lock.message !== ""
    property bool active: false
    property bool shaking: false

    color: "black"

    Connections {
        target: Lock

        function onMessageChanged() {
            if (Lock.messageIsError && Lock.message !== "")
                shake.restart();
        }
    }

    Timer {
        id: idle

        interval: 10000
        onTriggered: root.active = false
    }

    // The desktop as it was when locking; only seen while the scene slides in over it.
    Image {
        id: snapshot

        anchors.fill: parent
        // The screen isn't known for a moment after the surface is created; wait for it.
        source: Lock.hasSnapshot && root.screen ? "file://" + Lock.snapshotPath(root.screen.name) : ""
        cache: false
        visible: scene.progress < 1
        onStatusChanged: {
            if (status === Image.Ready)
                slideIn.start();
            else if (status === Image.Error && source != "")
                scene.progress = 1;
        }
    }

    // Slides down over the snapshot when there is one; otherwise (e.g. relocking after a restart)
    // it starts in place. Driven by progress rather than pixels, so the surface sizing up as it
    // appears doesn't affect it.
    Item {
        id: scene

        property real progress: Lock.hasSnapshot ? 0 : 1

        width: parent.width
        height: parent.height
        y: -(1 - progress) * height
        // Keeps the hidden password row (parked below the bottom edge) out of sight while sliding.
        clip: true

        NumberAnimation {
            id: slideIn

            target: scene
            property: "progress"
            from: 0
            to: 1
            duration: 380
            easing.type: Easing.OutCubic
        }

        LockBackdrop {
            anchors.fill: parent
            screen: root.screen
        }

        // Captures typing anywhere on the surface; the visible row just draws its state.
        TextInput {
            id: input

            width: 0
            height: 0
            opacity: 0
            text: Lock.password
            echoMode: TextInput.Password
            enabled: !Lock.authenticating
            focus: true
            onTextChanged: {
                Lock.password = text;
                root.active = true;
                idle.restart();
            }
            onAccepted: Lock.submit()
            Keys.onEscapePressed: {
                Lock.password = "";
                root.active = false;
            }
        }

        Item {
            id: row

            x: root.margin + (root.shaking ? shakeOffset : 0)
            width: parent.width - 2 * root.margin
            height: 64
            // Only `shown` animates, so the surface sizing up as it appears doesn't move the row.
            y: parent.height + 8 - shown * (height + 56)

            property real shakeOffset: 0
            property real shown: root.rowShown ? 1 : 0

            Behavior on shown {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 18

                Text {
                    text: Icons.lock
                    color: Lock.messageIsError && Lock.message !== "" ? Theme.red : root.ink
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 26
                }

                // One dot per character; they pulse while PAM checks.
                Row {
                    id: dots

                    spacing: 10
                    visible: Lock.password !== "" || Lock.authenticating

                    Repeater {
                        model: Lock.authenticating ? 6 : Lock.password.length

                        delegate: Rectangle {
                            required property int index

                            width: 12
                            height: 12
                            radius: 6
                            color: Lock.messageIsError && Lock.message !== "" ? Theme.red : root.ink
                            y: Lock.authenticating ? Math.sin((pulse.t + index * 0.6)) * 4 : 0
                        }
                    }
                }

                Text {
                    visible: Lock.password === "" && !Lock.authenticating
                    text: Lock.message !== "" ? Lock.message : "Type your password"
                    color: Lock.messageIsError && Lock.message !== "" ? Theme.red : root.inkMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 4
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    visible: Lock.unreadSinceLock > 0
                    text: Icons.bellBadge + "  " + Lock.unreadSinceLock
                    color: root.ink
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 4
                }
            }
        }
    }

    // Wrong password: the row shakes sideways.
    SequentialAnimation {
        id: shake

        PropertyAction {
            target: root
            property: "shaking"
            value: true
        }

        NumberAnimation {
            target: row
            property: "shakeOffset"
            to: -14
            duration: 50
        }

        NumberAnimation {
            target: row
            property: "shakeOffset"
            to: 12
            duration: 70
        }

        NumberAnimation {
            target: row
            property: "shakeOffset"
            to: -8
            duration: 70
        }

        NumberAnimation {
            target: row
            property: "shakeOffset"
            to: 0
            duration: 60
        }

        PropertyAction {
            target: root
            property: "shaking"
            value: false
        }
    }

    FrameAnimation {
        id: pulse

        property real t: 0

        running: Lock.authenticating
        onTriggered: t += frameTime * 8
    }

    // Any click brings the row up and returns focus to the hidden input.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            input.forceActiveFocus();
            root.active = true;
            idle.restart();
        }
    }
}
