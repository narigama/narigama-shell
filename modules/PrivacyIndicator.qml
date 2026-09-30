import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

// Red mic/camera/screen glyphs while an app is capturing; hidden otherwise.
BarButton {
    icon: [Privacy.micApps.length > 0 ? Icons.microphone : "", Privacy.cameraApps.length > 0 ? Icons.camera : "", Privacy.screenApps.length > 0 ? Icons.screenShare : ""].filter(i => i !== "").join(" ")
    color: Theme.red
    labelShow: false
    leftDropdown: "privacy"
}
