import QtQuick
import qs.components
import qs.config
import qs.services

// Toggles the idle inhibitor (keeps the screen from locking or sleeping).
BarButton {
    icon: Desk.idleInhibited ? Icons.coffee : Icons.coffeeOutline
    color: Desk.idleInhibited ? Theme.yellow : Theme.fgMuted
    onLeftClicked: Desk.idleInhibited = !Desk.idleInhibited
}
