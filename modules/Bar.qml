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
        anchors.left: parent.left
        height: parent.height

        Workspaces {
            visible: ShellState.moduleVisible("workspaces")
            screen: bar.screen
        }
    }

    Row {
        anchors.centerIn: parent
        height: parent.height

        MediaButton {}
    }

    Row {
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
