import QtQuick
import Quickshell
import qs.components
import qs.config

BarButton {
    icon: Icons.calendarClock
    label: Qt.formatDateTime(clock.date, ShellState.timeFormat)
    color: Theme.primary
    leftDropdown: "calendar"
    rightDropdown: "weather"

    SystemClock {
        id: clock

        precision: ShellState.clockSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }
}
