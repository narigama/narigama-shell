import QtQuick
import Quickshell.Services.Pipewire
import qs.components
import qs.config

BarButton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    icon: Icons.forVolume(volume, muted)
    label: String(Math.round(volume * 100)).padStart(2, "0") + "%"
    color: Theme.red
    leftDropdown: "audio"

    onMiddleClicked: {
        if (sink?.audio)
            sink.audio.muted = !muted;
    }

    PwObjectTracker {
        objects: [root.sink]
    }
}
