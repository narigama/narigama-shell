import QtQuick
import qs.components
import qs.config
import qs.services

// Left click picks a colour (copied to the clipboard); right click lists recent picks.
BarButton {
    icon: Icons.eyedropper
    iconColor: Capture.pickedColors[0] ?? Theme.fg
    rightDropdown: "colors"
    onLeftClicked: Capture.pickColor()
}
