pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Apps currently capturing the microphone, camera or screen, read from PipeWire links.
// Node types are bit flags (Audio 1, Video 2, Stream 4, Source 8, Sink 16); an app's capture
// stream is Stream|Source. media.class isn't used as it's only filled in for tracked nodes.
Singleton {
    id: root

    readonly property var captures: Pipewire.linkGroups.values.filter(g => {
        const target = g.target;
        const source = g.source;

        if (!target || !source)
            return false;

        const isCaptureStream = (target.type & PwNodeType.Stream) && (target.type & PwNodeType.Source);
        // Capturing a sink's monitor is recording playback, not the mic.
        const fromSink = (source.type & PwNodeType.Sink) && !(source.type & PwNodeType.Stream);

        return isCaptureStream && !fromSink;
    })

    function kind(group) {
        if (!(group.target.type & PwNodeType.Video))
            return "mic";

        // xdg-desktop-portal-hyprland names its screencast nodes "xdph-streaming-…".
        return /xdph|screen|portal/i.test(group.source.name) ? "screen" : "camera";
    }

    function appsFor(kindName) {
        return [...new Set(captures.filter(g => kind(g) === kindName).map(g => g.target.name))];
    }

    readonly property var micApps: appsFor("mic")
    readonly property var cameraApps: appsFor("camera")
    readonly property var screenApps: appsFor("screen")
    readonly property bool active: captures.length > 0
}
