import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property MprisPlayer player: Media.active

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds));

        return Math.floor(total / 60) + ":" + String(total % 60).padStart(2, "0");
    }

    width: 380
    spacing: 12

    StyledText {
        visible: root.player === null
        text: "Nothing playing"
        color: Theme.fgMuted
    }

    RowLayout {
        visible: root.player !== null
        Layout.fillWidth: true
        spacing: 16

        Rectangle {
            Layout.preferredWidth: 96
            Layout.preferredHeight: 96
            color: Theme.elevated

            StyledText {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Icons.forPlayer(root.player)
                font.family: Theme.iconFontFamily
                color: Theme.blue
                font.pixelSize: 40
            }

            Image {
                id: art

                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(192, 192)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            StyledText {
                Layout.fillWidth: true
                text: root.player?.trackTitle || "Unknown title"
                color: Theme.blue
                font.bold: true
                font.pixelSize: Theme.fontSize + 2
            }

            StyledText {
                Layout.fillWidth: true
                text: root.player?.trackArtist || "Unknown artist"
            }

            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.player?.trackAlbum ?? ""
                color: Theme.fgMuted
            }

            StyledText {
                Layout.fillWidth: true
                text: Media.playerName(root.player)
                color: Theme.fgSubtle
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    ColumnLayout {
        visible: root.player !== null && root.player.lengthSupported && root.player.length > 0
        Layout.fillWidth: true
        spacing: 4

        Slider {
            Layout.fillWidth: true
            accent: Theme.blue
            enabled: root.player?.canSeek ?? false
            value: root.player ? root.player.position / root.player.length : 0
            onMoved: value => root.player.position = value * root.player.length
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true
                text: root.formatTime(root.player?.position ?? 0)
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSize - 2
            }

            StyledText {
                text: root.formatTime(root.player?.length ?? 0)
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    RowLayout {
        visible: root.player !== null
        Layout.alignment: Qt.AlignHCenter
        spacing: 8

        IconButton {
            visible: root.player?.shuffleSupported ?? false
            icon: Icons.shuffle
            foreground: root.player?.shuffle ? Theme.blue : Theme.fgMuted
            onClicked: root.player.shuffle = !root.player.shuffle
        }

        IconButton {
            icon: Icons.skipPrevious
            enabled: root.player?.canGoPrevious ?? false
            onClicked: root.player.previous()
        }

        IconButton {
            icon: root.player?.isPlaying ? Icons.pause : Icons.play
            iconSize: 28
            implicitHeight: 40
            foreground: Theme.blue
            enabled: root.player?.canTogglePlaying ?? false
            onClicked: root.player.togglePlaying()
        }

        IconButton {
            icon: Icons.skipNext
            enabled: root.player?.canGoNext ?? false
            onClicked: root.player.next()
        }

        IconButton {
            visible: root.player?.loopSupported ?? false
            icon: root.player?.loopState === MprisLoopState.Track ? Icons.repeatOnce : root.player?.loopState === MprisLoopState.Playlist ? Icons.repeat : Icons.repeatOff
            foreground: root.player?.loopState === MprisLoopState.None ? Theme.fgMuted : Theme.blue
            onClicked: {
                const next = {
                    [MprisLoopState.None]: MprisLoopState.Playlist,
                    [MprisLoopState.Playlist]: MprisLoopState.Track,
                    [MprisLoopState.Track]: MprisLoopState.None
                };

                root.player.loopState = next[root.player.loopState];
            }
        }
    }

    SectionHeader {
        visible: Media.players.length > 1
        text: "Players"
    }

    Repeater {
        model: Media.players.length > 1 ? Media.players : []

        delegate: ListRow {
            required property MprisPlayer modelData

            icon: Icons.forPlayer(modelData)
            iconColor: Theme.blue
            title: Media.playerName(modelData)
            subtitle: modelData.trackTitle ? modelData.trackTitle + (modelData.trackArtist ? " - " + modelData.trackArtist : "") : ""
            highlighted: modelData === root.player
            onClicked: Media.chosen = modelData

            StyledText {
                text: modelData.isPlaying ? Icons.play : Icons.pause
                font.family: Theme.iconFontFamily
                color: Theme.fgMuted
            }
        }
    }
}
