import QtQuick
import Quickshell.Networking
import qs.components
import qs.config
import qs.services

BarButton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && (d.connected || d.state === ConnectionState.Connecting)) ?? null
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null

    icon: {
        const net = wired ? Icons.ethernet : !wifi ? Icons.lanDisconnect : !Networking.wifiEnabled ? Icons.wifiOff : wifi.state === ConnectionState.Connecting ? Icons.wifiAlert : wifiNetwork ? Icons.forWifiSignal(wifiNetwork.signalStrength) : Icons.wifiOffline;

        return Vpn.connected || Vpn.connecting ? net + " " + Icons.shieldLock : net;
    }
    labelShow: false
    color: Vpn.connecting ? Theme.yellow : Vpn.connected ? Theme.green : Theme.primary
    leftDropdown: "network"
}
