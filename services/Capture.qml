pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Screenshots (grim/slurp, optionally annotated in satty), screen recording (wf-recorder) and
// the colour picker (hyprpicker). Files land under the XDG Pictures and Videos folders.
Singleton {
    id: root

    readonly property string screenshotDir: Tools.picturesDir + "/Screenshots"
    readonly property string recordingDir: Tools.videosDir + "/Recordings"

    readonly property bool recording: recorder.running
    property double recordingStartedAt: 0
    property string recordingFile: ""
    // Ticks once a second while recording, for the elapsed-time label.
    property double now: Date.now()
    readonly property string recordingElapsed: {
        const seconds = Math.max(0, Math.floor((now - recordingStartedAt) / 1000));

        return Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0");
    }

    // Most recent first, as "#rrggbb".
    property var pickedColors: []

    function timestamp() {
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss");
    }

    // `screen` is a screen name for a whole output, or "" to pick a region with slurp.
    // Delayed so an open dropdown has slid away before grim captures.
    function screenshot(screen) {
        pending.action = () => {
            const file = root.screenshotDir + "/" + timestamp() + ".png";
            const grab = screen !== "" ? "grim -o '" + screen + "' -" : "geometry=$(slurp) || exit 0; grim -g \"$geometry\" -";
            const finish = ShellState.captureAnnotate && Tools.has("satty") ? " | satty --filename - --output-filename '" + file + "' --copy-command wl-copy --early-exit" : " > '" + file + "' && wl-copy < '" + file + "' && notify-send -a Screenshot -i '" + file + "' 'Screenshot saved' '" + file + "'";

            Quickshell.execDetached(["sh", "-c", "mkdir -p '" + root.screenshotDir + "'; " + grab + finish]);
        };
        pending.restart();
    }

    function startRecording(screen) {
        if (recording)
            return;

        pending.action = () => {
            recordingFile = root.recordingDir + "/" + timestamp() + ".mp4";
            const target = screen !== "" ? "-o '" + screen + "'" : "-g \"$geometry\"";
            const pick = screen !== "" ? "" : "geometry=$(slurp) || exit 0; ";

            recorder.command = ["sh", "-c", "mkdir -p '" + root.recordingDir + "'; " + pick + "exec wf-recorder " + target + (ShellState.captureAudio ? " --audio" : "") + " -f '" + recordingFile + "'"];
            recordingStartedAt = Date.now();
            recorder.running = true;
        };
        pending.restart();
    }

    function stopRecording() {
        if (recording)
            recorder.signal(2);
    }

    function pickColor() {
        pending.action = () => picker.running = true;
        pending.restart();
    }

    function copyColor(color) {
        Quickshell.execDetached(["wl-copy", color]);
        Osd.show(Icons.eyedropper, color + " copied", -1, color);
    }

    Timer {
        id: pending

        property var action: null

        interval: 250
        onTriggered: action?.()
    }

    Timer {
        interval: 1000
        running: root.recording
        repeat: true
        onTriggered: root.now = Date.now()
    }

    Process {
        id: recorder

        onExited: (code, status) => {
            // A cancelled slurp exits before wf-recorder ever starts, leaving no file.
            if (Date.now() - root.recordingStartedAt > 1500)
                Quickshell.execDetached(["sh", "-c", "[ -s '" + root.recordingFile + "' ] && notify-send -a Recording 'Recording saved' '" + root.recordingFile + "'"]);
        }
    }

    Process {
        id: picker

        command: ["hyprpicker", "--format=hex", "--quiet"]
        stdout: StdioCollector {
            onStreamFinished: {
                const color = text.trim().toLowerCase();

                if (!/^#[0-9a-f]{6}$/.test(color))
                    return;

                root.pickedColors = [color].concat(root.pickedColors.filter(c => c !== color)).slice(0, 12);
                root.copyColor(color);
            }
        }
    }
}
