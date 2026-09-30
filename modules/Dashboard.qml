import QtQuick
import qs.components
import qs.config

BarButton {
    icon: Icons.archlinux
    color: Theme.yellow
    leftDropdown: "dashboard"
    relatedDropdowns: ["settings"]
}
