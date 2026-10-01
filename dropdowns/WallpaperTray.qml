import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services

// Wallpaper carousel for the bar's tray. The strip's scroll position follows the pointer's x across
// it (left edge shows the first wallpaper, right edge the last); clicking applies one.
ColumnLayout {
    id: root

    // Screen names to apply to; empty means all.
    property var targets: []
    readonly property int thumbHeight: 180
    readonly property int thumbWidth: 320
    readonly property int thumbGap: 12

    spacing: 12

    Component.onCompleted: Wallpapers.scan()

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        StyledText {
            text: "Apply to"
            color: Theme.fgMuted
        }

        IconButton {
            text: "All"
            implicitHeight: 26
            active: root.targets.length === 0
            background: Theme.surface
            onClicked: root.targets = []
        }

        Repeater {
            model: Quickshell.screens

            delegate: IconButton {
                required property ShellScreen modelData

                text: modelData.name
                implicitHeight: 26
                active: root.targets.includes(modelData.name)
                background: Theme.surface
                onClicked: root.targets = root.targets.includes(modelData.name) ? root.targets.filter(n => n !== modelData.name) : root.targets.concat([modelData.name])
            }
        }

        Item {
            Layout.preferredWidth: 24
        }

        StyledText {
            text: "Match wallpaper colours"
            color: Tools.has("matugen") ? Theme.fgMuted : Theme.fgSubtle
        }

        Toggle {
            visible: Tools.has("matugen")
            checked: ShellState.matchWallpaper
            onToggled: ShellState.matchWallpaper = !ShellState.matchWallpaper
        }

        Repeater {
            model: Tools.has("matugen") && ShellState.matchWallpaper ? [["dark", "Dark"], ["light", "Light"]] : []

            delegate: IconButton {
                required property var modelData

                text: modelData[1]
                implicitHeight: 26
                active: ShellState.wallpaperThemeMode === modelData[0]
                background: Theme.surface
                onClicked: ShellState.wallpaperThemeMode = modelData[0]
            }
        }

        StyledText {
            visible: !Tools.has("matugen")
            text: Tools.optionalHint("matugen")
            color: Theme.yellow
            font.pixelSize: Theme.fontSize - 3
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: Wallpapers.scanning ? "Making thumbnails…" : Wallpapers.wallpapers.length + " images"
            color: Theme.fgSubtle
            font.pixelSize: Theme.fontSize - 2
        }

        TextField {
            id: folder

            Layout.preferredWidth: 360
            text: Wallpapers.folder
            placeholder: "Wallpaper folder"
            onAccepted: setFolder.clicked()
        }

        IconButton {
            id: setFolder

            text: "Set"
            foreground: Theme.primary
            enabled: folder.text.trim() !== "" && folder.text.trim() !== Wallpapers.folder
            onClicked: ShellState.wallpaperDir = folder.text.trim().replace(/\/$/, "")
        }

        IconButton {
            icon: Icons.refresh
            iconSize: Theme.fontSize + 2
            implicitHeight: 26
            foreground: Theme.fgMuted
            enabled: !Wallpapers.scanning
            onClicked: Wallpapers.scan()
        }

        // Leaves room for the tray's close button.
        Item {
            Layout.preferredWidth: 28
        }
    }

    StyledText {
        visible: !Tools.available("wallpapers")
        text: Tools.hint("wallpapers")
        color: Theme.yellow
    }

    StyledText {
        visible: Tools.available("wallpapers") && !Wallpapers.scanning && Wallpapers.wallpapers.length === 0
        text: "No images (jpg, png, webp) in " + Wallpapers.folder
        color: Theme.fgMuted
    }

    Item {
        id: viewport

        readonly property real overflow: Math.max(0, strip.width - width)
        // 0..1 across the viewport, eased so the strip glides instead of tracking every pixel.
        property real pointerFraction: 0

        Layout.fillWidth: true
        implicitHeight: root.thumbHeight + 28
        clip: true

        HoverHandler {
            id: hover

            onPointChanged: viewport.pointerFraction = Math.max(0, Math.min(1, point.position.x / viewport.width))
        }

        Row {
            id: strip

            x: -viewport.overflow * viewport.pointerFraction
            spacing: root.thumbGap

            Behavior on x {
                // A fixed duration rather than a velocity, so long strips keep up with the pointer.
                SmoothedAnimation {
                    velocity: -1
                    duration: 300
                }
            }

            Repeater {
                model: Wallpapers.wallpapers

                delegate: Item {
                    id: thumb

                    required property var modelData
                    readonly property bool selected: Wallpapers.isCurrent(modelData.path)

                    width: root.thumbWidth
                    height: root.thumbHeight + 28

                    Rectangle {
                        id: frame

                        width: parent.width
                        height: root.thumbHeight
                        color: Theme.surface
                        border.color: thumb.selected ? Theme.primary : thumbMouse.containsMouse ? Theme.fgMuted : "transparent"
                        border.width: thumb.selected ? 3 : 2

                        Image {
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            source: "file://" + thumb.modelData.thumb
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            sourceSize.width: root.thumbWidth
                        }
                    }

                    StyledText {
                        anchors.top: frame.bottom
                        anchors.topMargin: 6
                        width: parent.width
                        text: thumb.modelData.name
                        color: thumb.selected ? Theme.primary : Theme.fgSubtle
                        font.pixelSize: Theme.fontSize - 2
                        elide: Text.ElideMiddle
                    }

                    MouseArea {
                        id: thumbMouse

                        anchors.fill: frame
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpapers.apply(thumb.modelData.path, root.targets)
                    }
                }
            }
        }
    }
}
