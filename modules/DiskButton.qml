import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    readonly property real percent: SystemHealth.rootPercent

    icon: Icons.harddisk
    label: Math.round(percent) + "%"
    color: percent >= 90 ? Theme.red : percent >= 75 ? Theme.yellow : Theme.blue
    leftDropdown: "disk"
}
