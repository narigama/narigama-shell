import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config
import qs.services

// The lock screen's background and clock for one screen, shared by the lock surface and the
// overlay that slides away after unlocking, so the hand-over between them is invisible.
Item {
    id: root

    required property ShellScreen screen
    readonly property string wallpaper: Wallpapers.current[screen?.name ?? ""] ?? ShellState.wallpaper
    // The desktop snapshot when asked for and taken; the wallpaper otherwise.
    readonly property string backgroundSource: {
        if (ShellState.lockBackground === "desktop" && Lock.hasSnapshot && screen)
            return "file://" + Lock.snapshotPath(screen.name);

        return wallpaper !== "" ? "file://" + wallpaper : "";
    }
    readonly property string effect: ShellState.lockEffect
    readonly property bool ready: background.status === Image.Ready || backgroundSource === ""
    readonly property color ink: "#f4f1ec"
    readonly property color inkMuted: "#b8b2aa"
    readonly property int margin: 72

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // Drawn past the screen edges so the blur doesn't fade to the background colour at the borders.
    Image {
        id: background

        anchors.fill: parent
        anchors.margins: root.effect === "blur" ? -48 : 0
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        // Pixelate: decode at a fraction of the screen size, then scale up without smoothing.
        sourceSize.width: root.effect === "pixelate" ? Math.max(8, Math.round(root.width / (4 + 4 * ShellState.lockEffectStrength))) : 0
        smooth: root.effect !== "pixelate"
        visible: root.effect !== "blur"
    }

    MultiEffect {
        anchors.fill: background
        source: background
        visible: root.effect === "blur" && background.status === Image.Ready
        blurEnabled: true
        blur: Math.min(1, 0.1 * ShellState.lockEffectStrength)
        blurMax: 64
        saturation: -0.1
    }

    // Only where text sits: a full-height wash from the left behind the clock (no edge to see), and
    // a band along the bottom.
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.6
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: Qt.rgba(0, 0, 0, 0.45)
            }

            GradientStop {
                position: 1
                color: "transparent"
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 220
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "transparent"
            }

            GradientStop {
                position: 1
                color: Qt.rgba(0, 0, 0, 0.6)
            }
        }
    }

    Column {
        id: clockColumn

        x: root.margin
        y: root.margin - 20
        spacing: 0

        Text {
            text: Qt.formatDateTime(clock.date, ShellState.clock24h ? "HH:mm" : "h:mm")
            color: root.ink
            font.family: Theme.fontFamily
            font.pixelSize: 168
            font.weight: Font.Light
        }

        Text {
            leftPadding: 8
            text: Qt.formatDateTime(clock.date, "dddd d MMMM").toUpperCase()
            color: root.inkMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 4
            font.letterSpacing: 4
        }
    }
}
