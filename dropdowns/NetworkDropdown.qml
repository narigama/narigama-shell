import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wiredDevices: devices.filter(d => d.type === DeviceType.Wired)
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    // Sorted by signal bucket rather than raw strength, and only reassigned when the order changes:
    // a new array makes the Repeater rebuild every row, dropping a half-typed password.
    readonly property var sortedNetworks: (wifi?.networks.values ?? []).filter(n => n.name !== "").sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (Math.ceil(b.signalStrength * 4) - Math.ceil(a.signalStrength * 4)) || a.name.localeCompare(b.name))
    readonly property string sortedKey: sortedNetworks.map(n => n.name).join("\n")
    property var networks: []

    // Deferred: rebuilding rows mid-layout (scan results arrive while the host measures us) is a binding loop.
    onSortedKeyChanged: Qt.callLater(() => networks = sortedNetworks)
    // Name of the secured network currently asking for a password.
    property string passwordFor: ""

    function stateText(state) {
        return {
            [ConnectionState.Connecting]: "Connecting…",
            [ConnectionState.Connected]: "Connected",
            [ConnectionState.Disconnecting]: "Disconnecting…",
            [ConnectionState.Disconnected]: "Disconnected"
        }[state] ?? "Unknown";
    }

    function activate(network) {
        if (network.connected) {
            network.disconnect();
            return;
        }

        if (network.known || network.security === WifiSecurityType.Open) {
            network.connect();
            return;
        }

        passwordFor = passwordFor === network.name ? "" : network.name;
    }

    width: 380
    spacing: 8

    // Keep the wifi list fresh only while the dropdown is open.
    Component.onCompleted: {
        networks = sortedNetworks;
        Vpn.refresh();

        if (wifi)
            Qt.callLater(() => wifi.scannerEnabled = true);
    }
    Component.onDestruction: {
        if (wifi)
            wifi.scannerEnabled = false;
    }

    SectionHeader {
        text: "Traffic"
    }

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: Icons.arrowDown + " " + SystemStats.formatRate(SystemStats.rxRate)
            color: Theme.primary
        }

        StyledText {
            text: Icons.arrowUp + " " + SystemStats.formatRate(SystemStats.txRate)
            color: Theme.green
        }
    }

    // Both directions on one scale, so their heights compare.
    Item {
        Layout.fillWidth: true
        implicitHeight: 40

        Sparkline {
            anchors.fill: parent
            values: SystemStats.rxHistory
            maximum: Math.max(1024, ...SystemStats.rxHistory, ...SystemStats.txHistory)
            color: Theme.primary
        }

        Sparkline {
            anchors.fill: parent
            values: SystemStats.txHistory
            maximum: Math.max(1024, ...SystemStats.rxHistory, ...SystemStats.txHistory)
            color: Theme.green
        }
    }

    SectionHeader {
        visible: Vpn.available
        text: "VPN"

        IconButton {
            visible: Vpn.hasProtonApp
            icon: Icons.application
            text: "App"
            iconSize: Theme.fontSize
            implicitHeight: 24
            foreground: Theme.fgMuted
            onClicked: Vpn.openProtonApp()
        }
    }

    ListRow {
        visible: Vpn.hasProton
        icon: Vpn.protonConnected ? Icons.shieldLock : Icons.shieldOutline
        iconColor: Vpn.protonBusy ? Theme.yellow : Vpn.protonConnected ? Theme.green : Theme.fgMuted
        title: "Proton VPN"
        subtitle: Vpn.protonBusy ? (Vpn.protonAction === "disconnecting" || Vpn.protonConnected ? "Disconnecting…" : "Connecting…") : Vpn.protonConnected ? "Connected" + (Vpn.protonServer ? " · " + Vpn.protonServer : "") : "Fastest server"
        highlighted: Vpn.protonConnected
        clickable: !Vpn.protonBusy
        onClicked: Vpn.toggleProton()
    }

    RowLayout {
        visible: Vpn.hasProton
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: Vpn.protonCountries

            delegate: IconButton {
                required property string modelData

                Layout.fillWidth: true
                text: modelData
                implicitHeight: 28
                enabled: !Vpn.protonBusy
                active: Vpn.protonConnected && Vpn.protonCountry === modelData
                background: Theme.surface
                onClicked: Vpn.connectProtonCountry(modelData)
            }
        }
    }

    Repeater {
        model: Vpn.profiles

        delegate: ListRow {
            required property var modelData
            readonly property bool busy: Vpn.busyProfile === modelData.id || modelData.connecting

            icon: modelData.connected ? Icons.shieldLock : Icons.shieldOutline
            iconColor: busy ? Theme.yellow : modelData.connected ? Theme.green : Theme.fgMuted
            title: modelData.name
            subtitle: [modelData.kind === "wireguard" ? "WireGuard" : "VPN", busy ? (modelData.connected || modelData.state === "deactivating" ? "Disconnecting…" : "Connecting…") : modelData.connected ? "Connected" : ""].filter(t => t !== "").join(" · ")
            highlighted: modelData.connected
            clickable: !busy
            onClicked: Vpn.toggleProfile(modelData)
        }
    }

    SectionHeader {
        Layout.topMargin: Vpn.available ? 8 : 0
        visible: root.wiredDevices.length > 0
        text: "Wired"
    }

    Repeater {
        model: root.wiredDevices

        delegate: ListRow {
            required property var modelData

            icon: modelData.connected ? Icons.ethernet : Icons.lanDisconnect
            iconColor: modelData.connected ? Theme.primary : Theme.fgMuted
            title: modelData.name
            subtitle: modelData.hasLink ? root.stateText(modelData.state) + (modelData.linkSpeed > 0 ? " · " + modelData.linkSpeed + " Mb/s" : "") : "Cable unplugged"
            highlighted: modelData.connected
            clickable: modelData.connected
            onClicked: modelData.disconnect()
        }
    }

    SectionHeader {
        Layout.topMargin: root.wiredDevices.length > 0 || Vpn.available ? 8 : 0
        visible: root.wifi !== null
        text: "Wi-Fi"

        Toggle {
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    StyledText {
        visible: root.wifi !== null && Networking.wifiEnabled && root.networks.length === 0
        text: "Scanning…"
        color: Theme.fgMuted
    }

    Repeater {
        model: Networking.wifiEnabled ? root.networks : []

        delegate: ColumnLayout {
            id: networkItem

            required property var modelData
            readonly property bool secured: modelData.security !== WifiSecurityType.Open

            Layout.fillWidth: true
            spacing: 4

            ListRow {
                icon: Icons.forWifiSignal(networkItem.modelData.signalStrength)
                iconColor: networkItem.modelData.connected ? Theme.primary : Theme.fgMuted
                title: networkItem.modelData.name
                subtitle: [networkItem.modelData.stateChanging || networkItem.modelData.connected ? root.stateText(networkItem.modelData.state) : networkItem.modelData.known ? "Saved" : "", Math.round(networkItem.modelData.signalStrength * 100) + "%"].filter(t => t !== "").join(" · ")
                highlighted: networkItem.modelData.connected
                onClicked: root.activate(networkItem.modelData)

                StyledText {
                    visible: networkItem.secured
                    text: Icons.lockOutline
                    font.family: Theme.iconFontFamily
                    color: Theme.fgMuted
                }
            }

            RowLayout {
                visible: root.passwordFor === networkItem.modelData.name
                Layout.fillWidth: true
                Layout.leftMargin: 12
                spacing: 8

                TextField {
                    id: password

                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholder: "Password"
                    onAccepted: connectButton.clicked()
                    onVisibleChanged: {
                        if (visible)
                            focusInput();
                    }
                }

                IconButton {
                    id: connectButton

                    text: "Connect"
                    foreground: Theme.primary
                    enabled: password.text.length >= 8
                    onClicked: {
                        networkItem.modelData.connectWithPsk(password.text);
                        password.text = "";
                        root.passwordFor = "";
                    }
                }
            }
        }
    }
}
