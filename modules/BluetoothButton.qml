import QtQuick
import Quickshell.Bluetooth
import qs.components
import qs.config

BarButton {
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool anyConnected: Bluetooth.devices.values.some(d => d.connected)

    icon: {
        if (!adapter?.enabled)
            return Icons.bluetoothOff;

        if (anyConnected)
            return Icons.bluetoothConnect;

        return adapter.discovering ? Icons.bluetoothSearching : Icons.bluetooth;
    }
    labelShow: false
    color: Theme.blue
    leftDropdown: "bluetooth"
}
