import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Icons.cpu
    label: String(Math.round(SystemStats.cpuPercent)).padStart(2, "0") + "%"
    color: Theme.blue
    leftDropdown: "cpu"
}
