import QtQuick
import qs.components
import qs.config
import qs.services

BarButton {
    icon: Icons.forBattery(Power.level, Power.charging)
    label: Math.round(Power.level * 100) + "%"
    color: Power.low ? Theme.red : Power.charging ? Theme.green : Theme.fg
    leftDropdown: "battery"
}
