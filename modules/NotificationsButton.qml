import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Notifications.dnd ? Icons.bellOff : Notifications.count > 0 ? Icons.bellBadge : Icons.bell
    label: String(Notifications.count)
    color: Theme.green
    leftDropdown: "notifications"

    onRightClicked: Notifications.setDnd(!Notifications.dnd)
}
