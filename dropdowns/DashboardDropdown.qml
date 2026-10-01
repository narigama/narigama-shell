import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    property string hostname: ""
    property string kernel: ""
    property real uptimeSeconds: 0
    // Logout, reboot and power off need a second click within a few seconds.
    property string pending: ""
    // Tray item whose menu is expanded below the tray icons.
    property SystemTrayItem trayMenuItem: null
    readonly property var trayItems: SystemTray.items.values

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor(seconds % 86400 / 3600);
        const minutes = Math.floor(seconds % 3600 / 60);

        return (days > 0 ? days + "d " : "") + hours + "h " + minutes + "m";
    }

    function run(action, command, confirm) {
        if (confirm && pending !== action) {
            pending = action;
            confirmTimer.restart();
            return;
        }

        pending = "";
        Quickshell.execDetached(["sh", "-c", command]);
    }

    width: 340
    spacing: 12

    FileView {
        path: "/etc/hostname"
        onLoaded: root.hostname = text().trim()
    }

    FileView {
        path: "/proc/sys/kernel/osrelease"
        onLoaded: root.kernel = text().trim()
    }

    FileView {
        id: uptime

        path: "/proc/uptime"
        onLoaded: root.uptimeSeconds = Number(text().split(" ")[0])
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptime.reload()
    }

    Timer {
        id: confirmTimer

        interval: 3000
        onTriggered: root.pending = ""
    }

    RowLayout {
        spacing: 16

        StyledText {
            text: Icons.forDistro(Tools.distroId)
            font.family: Theme.iconFontFamily
            color: Theme.yellow
            font.pixelSize: 44
        }

        ColumnLayout {
            spacing: 2

            StyledText {
                text: Quickshell.env("USER") + "@" + root.hostname
                color: Theme.yellow
                font.bold: true
                font.pixelSize: Theme.fontSize + 2
            }

            StyledText {
                text: "Linux " + root.kernel
                color: Theme.fgMuted
            }

            StyledText {
                text: "Up " + root.formatUptime(root.uptimeSeconds)
                color: Theme.fgMuted
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 4
        columnSpacing: 4

        IconButton {
            Layout.fillWidth: true
            icon: Icons.cog
            text: "Settings"
            foreground: Theme.primary
            background: Theme.surface
            onClicked: Dropdowns.current = "settings"
        }

        IconButton {
            Layout.fillWidth: true
            icon: Icons.image
            text: "Wallpapers"
            foreground: Theme.primary
            background: Theme.surface
            onClicked: Dropdowns.current = "wallpapers"
        }
    }

    SectionHeader {
        visible: root.trayItems.length > 0
        text: "Tray"
    }

    Flow {
        visible: root.trayItems.length > 0
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: root.trayItems

            delegate: Rectangle {
                id: trayButton

                required property SystemTrayItem modelData

                function toggleMenu() {
                    root.trayMenuItem = root.trayMenuItem === modelData ? null : modelData;
                }

                implicitWidth: 36
                implicitHeight: 36
                color: root.trayMenuItem === modelData ? Theme.elevated : mouse.containsMouse ? Theme.surface : "transparent"

                TrayIcon {
                    anchors.centerIn: parent
                    item: trayButton.modelData
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton) {
                            trayButton.modelData.secondaryActivate();
                            return;
                        }

                        if (mouse.button === Qt.RightButton || trayButton.modelData.onlyMenu) {
                            if (trayButton.modelData.hasMenu)
                                trayButton.toggleMenu();

                            return;
                        }

                        trayButton.modelData.activate();
                        Dropdowns.close();
                    }

                    onWheel: wheel => trayButton.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }

    StyledText {
        visible: root.trayMenuItem !== null && root.trayItems.includes(root.trayMenuItem)
        Layout.fillWidth: true
        text: root.trayMenuItem ? (root.trayMenuItem.tooltipTitle || root.trayMenuItem.title || root.trayMenuItem.id) : ""
        color: Theme.fgMuted
        font.bold: true
    }

    TrayMenu {
        visible: root.trayMenuItem !== null && root.trayItems.includes(root.trayMenuItem)
        menu: visible ? root.trayMenuItem.menu : null
        onActivated: Dropdowns.close()
    }

    // Kept at the bottom, away from the page buttons, so they aren't hit by accident.
    GridLayout {
        Layout.fillWidth: true
        Layout.topMargin: 8
        columns: 2
        rowSpacing: 4
        columnSpacing: 4

        IconButton {
            Layout.fillWidth: true
            icon: Icons.lock
            text: "Lock"
            background: Theme.surface
            onClicked: root.run("lock", Config.lockCommand, false)
        }

        IconButton {
            Layout.fillWidth: true
            icon: Icons.logout
            text: root.pending === "logout" ? "Confirm?" : "Log out"
            foreground: Theme.yellow
            background: Theme.surface
            onClicked: root.run("logout", Config.logoutCommand, true)
        }

        IconButton {
            Layout.fillWidth: true
            icon: Icons.restart
            text: root.pending === "reboot" ? "Confirm?" : "Reboot"
            foreground: Theme.yellow
            background: Theme.surface
            onClicked: root.run("reboot", Config.rebootCommand, true)
        }

        IconButton {
            Layout.fillWidth: true
            icon: Icons.power
            text: root.pending === "poweroff" ? "Confirm?" : "Power off"
            foreground: Theme.red
            background: Theme.surface
            onClicked: root.run("poweroff", Config.poweroffCommand, true)
        }
    }
}
