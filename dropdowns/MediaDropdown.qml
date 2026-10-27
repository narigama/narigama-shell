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

    Component.onCompleted: Compositor.refreshWindows()

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
            id: artBox

            readonly property string rawUrl: root.player?.trackArtUrl ?? ""
            property string shownUrl: ""
            property string prevUrl: ""
            property bool ready: false

            Layout.preferredWidth: 96
            Layout.preferredHeight: 96
            color: Theme.elevated

            onRawUrlChanged: {
                if (!ready)
                    return;

                if (rawUrl === "") {
                    clearArtTimer.restart();
                    return;
                }

                clearArtTimer.stop();
                artFadeOut.stop();

                if (rawUrl !== shownUrl) {
                    if (shownUrl !== "" && art.status === Image.Ready) {
                        prevUrl = shownUrl;
                        prevArt.opacity = 1;
                    }

                    artFadeIn.stop();
                    art.opacity = 0;
                    shownUrl = rawUrl;

                    if (art.status === Image.Ready)
                        artFadeIn.restart();
                }
            }

            Component.onCompleted: {
                shownUrl = rawUrl;
                ready = true;
            }

            // Players briefly clear trackArtUrl between tracks; wait before dropping the cover.
            Timer {
                id: clearArtTimer

                interval: 200
                onTriggered: {
                    prevArt.opacity = 0;
                    artFadeOut.restart();
                }
            }

            StyledText {
                anchors.centerIn: parent
                opacity: art.status !== Image.Ready && prevArt.status !== Image.Ready ? 1 : 0
                text: Icons.forPlayer(root.player)
                font.family: Theme.iconFontFamily
                color: Theme.blue
                font.pixelSize: 40

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Image {
                id: prevArt

                anchors.fill: parent
                source: artBox.prevUrl
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(192, 192)
            }

            Image {
                id: art

                anchors.fill: parent
                source: artBox.shownUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(192, 192)

                onStatusChanged: {
                    if (status === Image.Ready && artBox.ready && opacity < 1)
                        artFadeIn.restart();
                }
            }

            NumberAnimation {
                id: artFadeIn

                target: art
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
                onFinished: prevArt.opacity = 0
            }

            NumberAnimation {
                id: artFadeOut

                target: art
                property: "opacity"
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
                onFinished: {
                    artBox.prevUrl = "";
                    artBox.shownUrl = "";
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Media.focusPlayer(root.player);
                    Dropdowns.close();
                }
            }
        }

        ColumnLayout {
            readonly property string trackKey: `${root.player?.trackTitle ?? ""}\n${root.player?.trackArtist ?? ""}\n${root.player?.trackAlbum ?? ""}`

            Layout.fillWidth: true
            spacing: 4

            RollingText {
                Layout.fillWidth: true
                text: root.player?.trackTitle || "Unknown title"
                trigger: parent.trackKey
                color: Theme.blue
                bold: true
                pixelSize: Theme.fontSize + 2
            }

            RollingText {
                Layout.fillWidth: true
                text: root.player?.trackArtist || "Unknown artist"
                trigger: parent.trackKey
                delay: 75
            }

            RollingText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.player?.trackAlbum ?? ""
                trigger: parent.trackKey
                delay: 150
                color: Theme.fgMuted
            }

            RollingText {
                Layout.fillWidth: true
                text: Media.playerName(root.player)
                color: Theme.fgSubtle
                pixelSize: Theme.fontSize - 2
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
            // One seek on release; seeking on every move makes players report stale positions mid-drag.
            onReleased: value => root.player.position = value * root.player.length
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

            IconButton {
                icon: modelData.isPlaying ? Icons.play : Icons.pause
                foreground: Theme.fgMuted
                onClicked: modelData.togglePlaying()
            }
        }
    }
}
