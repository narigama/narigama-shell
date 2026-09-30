import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.components
import qs.config

ColumnLayout {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property var devices: (adapter?.devices.values ?? []).filter(d => d.paired || d.name !== d.address.replace(/:/g, "-")).sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
    // Discovery started from here is stopped again when the dropdown closes.
    property bool startedDiscovery: false

    function stateText(device) {
        if (device.pairing)
            return "Pairing…";

        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting…";

        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";

        if (device.connected)
            return "Connected" + (device.batteryAvailable ? " · " + Math.round(device.battery * 100) + "%" : "");

        return device.paired ? "Paired" : "Available";
    }

    function activate(device) {
        if (device.connected) {
            device.disconnect();
            return;
        }

        if (!device.paired) {
            device.trusted = true;
            device.pair();
            return;
        }

        device.connect();
    }

    width: 360
    spacing: 8

    Component.onDestruction: {
        if (startedDiscovery && adapter)
            adapter.discovering = false;
    }

    StyledText {
        visible: root.adapter === null
        text: "No Bluetooth adapter"
        color: Theme.fgMuted
    }

    SectionHeader {
        visible: root.adapter !== null
        text: root.adapter?.name ?? "Bluetooth"

        IconButton {
            visible: root.adapter?.enabled ?? false
            icon: Icons.refresh
            text: root.adapter?.discovering ? "Scanning" : "Scan"
            iconSize: Theme.fontSize
            implicitHeight: 24
            active: root.adapter?.discovering ?? false
            onClicked: {
                root.adapter.discovering = !root.adapter.discovering;
                root.startedDiscovery = root.adapter.discovering;
            }
        }

        Toggle {
            anchors.verticalCenter: parent.verticalCenter
            checked: root.adapter?.enabled ?? false
            accent: Theme.blue
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }
    }

    StyledText {
        visible: (root.adapter?.enabled ?? false) && root.devices.length === 0
        text: "No devices. Scan to find some."
        color: Theme.fgMuted
    }

    Repeater {
        model: root.adapter?.enabled ? root.devices : []

        delegate: ListRow {
            required property BluetoothDevice modelData

            icon: Icons.forBluetoothDevice(modelData)
            iconColor: modelData.connected ? Theme.blue : Theme.fgMuted
            title: modelData.name
            subtitle: root.stateText(modelData)
            highlighted: modelData.connected
            onClicked: root.activate(modelData)
        }
    }
}
