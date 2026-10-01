import QtQuick
import qs.components
import qs.config
import qs.services

// Shown only while a systemd unit has failed (see Bar.moduleAvailable).
BarButton {
    icon: Icons.alertCircle
    label: String(SystemHealth.failedUnits.length)
    color: Theme.red
    leftDropdown: "failedUnits"
}
