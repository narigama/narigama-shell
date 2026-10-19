import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Icons.brightness
    label: Math.round(Backlight.screenFraction * 100) + "%"
    color: Theme.yellow
    leftDropdown: "backlight"
    onScrolledUp: Backlight.setScreen(Backlight.screenFraction + 0.05)
    onScrolledDown: Backlight.setScreen(Backlight.screenFraction - 0.05)
}
