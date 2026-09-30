import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Icons.memory
    label: String(Math.round(SystemStats.ramPercent)).padStart(2, "0") + "%"
    color: Theme.green
    leftDropdown: "ram"
}
