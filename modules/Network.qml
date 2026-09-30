import QtQuick
import Quickshell.Networking
import qs.components
import qs.config

BarButton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && (d.connected || d.state === ConnectionState.Connecting)) ?? null
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null

    icon: {
        if (wired)
            return Icons.ethernet;

        if (!wifi)
            return Icons.lanDisconnect;

        if (!Networking.wifiEnabled)
            return Icons.wifiOff;

        if (wifi.state === ConnectionState.Connecting)
            return Icons.wifiAlert;

        return wifiNetwork ? Icons.forWifiSignal(wifiNetwork.signalStrength) : Icons.wifiOffline;
    }
    labelShow: false
    color: Theme.primary
    leftDropdown: "network"
}
