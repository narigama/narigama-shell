pragma Singleton

import QtQuick
import Quickshell

// Fixed behaviour.
// User-adjustable settings live in ShellState.
Singleton {
    readonly property int weatherRefreshMs: 15 * 60 * 1000

    readonly property int notificationPopupGap: 8
    readonly property int notificationHistoryMax: 1000

    readonly property string lockCommand: "loginctl lock-session"
    readonly property string logoutCommand: "loginctl terminate-session $XDG_SESSION_ID"
    readonly property string rebootCommand: "systemctl reboot"
    readonly property string poweroffCommand: "systemctl poweroff"
}
