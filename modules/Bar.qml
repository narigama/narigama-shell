import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.surface

    WlrLayershell.namespace: "narigama-bar"

    Row {
        id: leftModules

        anchors.left: parent.left
        height: parent.height

        Workspaces {
            visible: ShellState.moduleVisible("workspaces")
            screen: bar.screen
        }
    }

    // Hidden rather than overlapping when the screen is too narrow for it between the side groups.
    Row {
        id: centerModules

        anchors.centerIn: parent
        height: parent.height
        visible: bar.width - 2 * Math.max(leftModules.width, rightModules.width) >= implicitWidth + 16

        MediaButton {}
    }

    Row {
        id: rightModules

        anchors.right: parent.right
        height: parent.height

        PrivacyIndicator {
            visible: Privacy.active && ShellState.moduleVisible("privacy")
        }

        WeatherButton {}

        Clock {
            visible: ShellState.moduleVisible("clock")
        }

        Volume {
            visible: ShellState.moduleVisible("volume")
        }

        Cpu {
            visible: ShellState.moduleVisible("cpu")
        }

        Ram {
            visible: ShellState.moduleVisible("ram")
        }

        NotificationsButton {
            visible: ShellState.moduleVisible("notifications")
        }

        Network {
            visible: ShellState.moduleVisible("network")
        }

        BluetoothButton {
            visible: ShellState.moduleVisible("bluetooth")
        }

        Dashboard {}
    }
}
