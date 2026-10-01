import QtQuick
import qs.components
import qs.config
import qs.services

// Scroll adjusts every DDC display together.
BarButton {
    icon: Icons.brightness
    label: Math.round(Desk.averageBrightness) + "%"
    color: Theme.yellow
    leftDropdown: "brightness"
    onScrolledUp: Desk.setAllBrightness(Desk.averageBrightness + 5)
    onScrolledDown: Desk.setAllBrightness(Desk.averageBrightness - 5)
}
