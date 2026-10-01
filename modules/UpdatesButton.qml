import QtQuick
import qs.components
import qs.config
import qs.services

// Shown only while updates are pending (see Bar.moduleAvailable).
BarButton {
    icon: Icons.packageUp
    label: String(SystemHealth.updates.length)
    color: Theme.yellow
    leftDropdown: "updates"
}
