import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Icons.forDistro(Tools.distroId)
    color: Theme.yellow
    leftDropdown: "dashboard"
    relatedDropdowns: ["settings", "wallpapers"]
}
