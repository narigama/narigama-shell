import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.config

ColumnLayout {
    id: root

    // media.class separates app playback from capture streams (recorders, visualisers), which isStream alone doesn't.
    readonly property var nodes: Pipewire.nodes.values.filter(n => n.audio !== null)
    readonly property var sinks: nodes.filter(n => n.properties["media.class"] === "Audio/Sink")
    readonly property var sources: nodes.filter(n => n.properties["media.class"] === "Audio/Source")
    readonly property var streams: nodes.filter(n => n.properties["media.class"] === "Stream/Output/Audio")

    function deviceName(node) {
        return node.description || node.nickname || node.name;
    }

    width: 400
    spacing: 8

    PwObjectTracker {
        objects: root.nodes
    }

    component VolumeControl: RowLayout {
        id: control

        required property PwNode node
        property string icon
        property string mutedIcon
        property color accent: Theme.red

        Layout.fillWidth: true
        spacing: 8

        IconButton {
            icon: control.node?.audio?.muted ? control.mutedIcon : control.icon
            foreground: control.node?.audio?.muted ? Theme.fgMuted : control.accent
            enabled: control.node !== null
            onClicked: control.node.audio.muted = !control.node.audio.muted
        }

        Slider {
            Layout.fillWidth: true
            accent: control.accent
            enabled: control.node !== null
            value: control.node?.audio?.volume ?? 0
            onMoved: value => control.node.audio.volume = value
        }

        StyledText {
            Layout.preferredWidth: 44
            horizontalAlignment: Text.AlignRight
            text: Math.round((control.node?.audio?.volume ?? 0) * 100) + "%"
            color: control.accent
            font.bold: true
        }
    }

    SectionHeader {
        text: "Output"
    }

    VolumeControl {
        node: Pipewire.defaultAudioSink
        icon: Icons.volumeHigh
        mutedIcon: Icons.volumeOff
    }

    Repeater {
        model: root.sinks

        delegate: ListRow {
            required property PwNode modelData

            icon: Icons.speaker
            title: root.deviceName(modelData)
            highlighted: modelData === Pipewire.defaultAudioSink
            onClicked: Pipewire.preferredDefaultAudioSink = modelData
        }
    }

    SectionHeader {
        Layout.topMargin: 8
        text: "Input"
    }

    VolumeControl {
        node: Pipewire.defaultAudioSource
        icon: Icons.microphone
        mutedIcon: Icons.microphoneOff
        accent: Theme.yellow
    }

    Repeater {
        model: root.sources

        delegate: ListRow {
            required property PwNode modelData

            icon: Icons.microphone
            title: root.deviceName(modelData)
            highlighted: modelData === Pipewire.defaultAudioSource
            onClicked: Pipewire.preferredDefaultAudioSource = modelData
        }
    }

    SectionHeader {
        Layout.topMargin: 8
        visible: root.streams.length > 0
        text: "Applications"
    }

    Repeater {
        model: root.streams

        delegate: ColumnLayout {
            required property PwNode modelData

            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                text: (modelData.properties["application.name"] || modelData.name) + (modelData.properties["media.name"] ? " · " + modelData.properties["media.name"] : "")
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSize - 2
            }

            VolumeControl {
                node: modelData
                icon: Icons.volumeHigh
                mutedIcon: Icons.volumeOff
            }
        }
    }
}
