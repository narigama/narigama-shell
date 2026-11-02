import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// Mic/camera/screen glyphs while an app is capturing; right-click toggles mic mute.
BarButton {
    icon: [Privacy.micApps.length > 0 ? (Privacy.micMuted ? Icons.microphoneOff : Icons.microphone) : "", Privacy.cameraApps.length > 0 ? Icons.camera : "", Privacy.screenApps.length > 0 ? Icons.screenShare : ""].filter(i => i !== "").join(" ")
    color: Privacy.micMuted && Privacy.cameraApps.length === 0 && Privacy.screenApps.length === 0 ? Theme.fgMuted : Theme.red
    labelShow: false
    leftDropdown: "privacy"

    onRightClicked: Privacy.toggleMic()
}
