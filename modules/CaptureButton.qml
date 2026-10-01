import QtQuick
import qs.components
import qs.config
import qs.services

// Opens the capture menu; while recording, shows the elapsed time and a click stops it.
BarButton {
    icon: Capture.recording ? Icons.record : Icons.screenshot
    label: Capture.recording ? Capture.recordingElapsed : ""
    color: Capture.recording ? Theme.red : Theme.fg
    leftDropdown: Capture.recording ? "" : "capture"
    onLeftClicked: {
        if (Capture.recording)
            Capture.stopRecording();
    }
}
