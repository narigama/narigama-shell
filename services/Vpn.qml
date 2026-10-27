pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// WireGuard, NetworkManager VPN profiles and Proton VPN (CLI + GTK app).
// Watched through `nmcli monitor` and `ip monitor link` so external CLI/GUI changes show immediately.
Singleton {
    id: root

    readonly property bool hasProton: Tools.has("protonvpn")
    readonly property bool hasProtonApp: Tools.has("protonvpn-app")
    property bool protonConnected: false
    property bool protonActivating: false
    property string protonAction: ""
    readonly property bool protonBusy: protonProc.running || protonActivating
    property string protonServer: ""
    readonly property string protonCountry: protonServer.match(/^[A-Z]{2}/)?.[0] ?? ""
    readonly property var defaultCountries: ["UK", "IE", "FR", "DE", "NL", "US"]
    property var protonCountries: defaultCountries

    // [{ id, uuid, name, kind ("wireguard" | "vpn"), state, connected, connecting, external }]
    property var profiles: []
    property string busyProfile: ""
    property string busyProfileAction: ""

    readonly property bool available: hasProton || hasProtonApp || profiles.length > 0
    readonly property var activeConnections: [...(protonConnected ? ["Proton VPN" + (protonServer ? " (" + protonServer + ")" : "")] : []), ...profiles.filter(p => p.connected).map(p => p.name)]
    readonly property bool connected: activeConnections.length > 0
    readonly property bool connecting: protonBusy || busyProfile !== "" || profiles.some(p => p.connecting)
    readonly property string activeName: activeConnections[0] ?? ""

    function refresh() {
        if (query.running)
            debounce.restart();
        else
            query.running = true;
    }

    function toggleProton() {
        if (protonBusy)
            return;

        if (protonConnected) {
            protonAction = "disconnecting";
            protonProc.command = ["protonvpn", "disconnect"];
        } else {
            protonAction = "connecting";
            protonProc.command = ["sh", "-c", "protonvpn connect || protonvpn connect --random"];
        }

        protonProc.running = true;
    }

    function connectProtonCountry(country) {
        if (protonBusy)
            return;

        if (protonConnected && protonCountry === country) {
            toggleProton();
            return;
        }

        protonAction = "connecting";
        protonProc.command = ["sh", "-c", "protonvpn connect --country " + country + " || protonvpn connect --country " + country + " --random"];
        protonProc.running = true;
    }

    function openProtonApp() {
        Dropdowns.close();
        Quickshell.execDetached(["protonvpn-app"]);
    }

    function toggleProfile(profile) {
        if (busyProfile !== "" || profile.connecting)
            return;

        busyProfile = profile.id;
        busyProfileAction = profile.connected ? "disconnecting" : "connecting";

        if (profile.uuid !== "") {
            profileProc.command = ["nmcli", "connection", profile.connected ? "down" : "up", "uuid", profile.uuid];
        } else {
            const action = profile.connected ? "down" : "up";

            profileProc.command = ["sh", "-c", "wg-quick " + action + " '" + profile.name + "' 2>/dev/null || pkexec wg-quick " + action + " '" + profile.name + "'"];
        }

        profileProc.running = true;
    }

    Component.onCompleted: {
        if (Tools.ready)
            refresh();
    }

    Connections {
        target: Tools

        function onReadyChanged() {
            root.refresh();
        }
    }

    Timer {
        id: debounce

        interval: 150
        onTriggered: root.refresh()
    }

    Process {
        running: Tools.has("nmcli")
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Process {
        running: true
        command: ["ip", "monitor", "link"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Process {
        id: protonProc

        onExited: {
            root.protonAction = "";
            root.refresh();
        }
    }

    Process {
        id: profileProc

        onExited: {
            root.busyProfile = "";
            root.busyProfileAction = "";
            root.refresh();
        }
    }

    Process {
        id: query

        command: ["sh", "-c", `
            if command -v nmcli >/dev/null 2>&1; then
                nmcli -t -f UUID,TYPE,STATE,DEVICE,NAME connection show 2>/dev/null | sed 's/^/nm\\t/'
            fi
            ip -br link show type wireguard 2>/dev/null | awk '{print "wg\\t"$1"\\t"$2}'
            for f in /etc/wireguard/*.conf "\${XDG_CONFIG_HOME:-$HOME/.config}"/wireguard/*.conf; do
                [ -e "$f" ] && printf 'wgconf\\t%s\\n' "$(basename "$f" .conf)"
            done 2>/dev/null
            if [ -f "\${XDG_CACHE_HOME:-$HOME/.cache}/Proton/VPN/connection/connection_persistence.json" ]; then
                tr -d '\\n' < "\${XDG_CACHE_HOME:-$HOME/.cache}/Proton/VPN/connection/connection_persistence.json" | sed 's/^/proton\\t/; s/$/\\n/'
            fi
            if [ -f "\${XDG_CACHE_HOME:-$HOME/.cache}/Proton/VPN/logs/vpn-cli.log" ]; then
                grep -o 'Server: [A-Z][A-Z]#[0-9]*' "\${XDG_CACHE_HOME:-$HOME/.cache}/Proton/VPN/logs/vpn-cli.log" 2>/dev/null | cut -d' ' -f2 | cut -d'#' -f1 | tail -n 20 | tac | awk '!seen[$0]++' | tr '\\n' ',' | sed 's/^/recent\\t/; s/,$//; s/$/\\n/'
            fi`]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l !== "");
                let persistedUuid = "";
                let persistedServer = "";

                for (const line of lines) {
                    if (!line.startsWith("proton\t"))
                        continue;

                    try {
                        const data = JSON.parse(line.slice(7));

                        persistedUuid = data.connection_id ?? "";
                        persistedServer = data.server?.server_name ?? "";
                    } catch (e) {}
                }

                // NetworkManager marks proton0 "activated" as soon as the WireGuard netdev exists,
                // before Proton VPN's local-agent handshake finishes and writes connection_persistence.json.
                const protonReady = persistedUuid !== "" && root.protonAction !== "connecting";
                let pConn = false;
                let pAct = false;
                let pServer = "";
                const nmProfiles = [];
                const nmDevices = new Set();
                const nmNames = new Set();

                for (const line of lines) {
                    if (!line.startsWith("nm\t"))
                        continue;

                    const parts = line.slice(3).split(":");
                    const uuid = parts[0] ?? "";
                    const type = parts[1] ?? "";
                    const state = parts[2] ?? "";
                    const device = parts[3] ?? "";
                    const name = parts.slice(4).join(":").replace(/\\:/g, ":");

                    if (name.startsWith("pvpn-") || device === "pvpnksintrf0")
                        continue;

                    const isProton = name.startsWith("ProtonVPN") || device === "proton0" || (persistedUuid !== "" && uuid === persistedUuid);

                    if (isProton) {
                        if (device)
                            nmDevices.add(device);

                        if (state === "activated") {
                            if (protonReady)
                                pConn = true;
                            else
                                pAct = true;

                            pServer = name.replace(/^ProtonVPN\s*/, "") || persistedServer;
                        } else if (state === "activating" || state === "deactivating") {
                            pAct = true;
                            pServer = name.replace(/^ProtonVPN\s*/, "") || persistedServer;
                        }

                        continue;
                    }

                    if (type !== "wireguard" && type !== "vpn")
                        continue;

                    if (device)
                        nmDevices.add(device);

                    nmNames.add(name);
                    nmProfiles.push({
                        "id": uuid,
                        "uuid": uuid,
                        "name": name,
                        "kind": type === "wireguard" ? "wireguard" : "vpn",
                        "state": state,
                        "connected": state === "activated",
                        "connecting": state === "activating" || state === "deactivating",
                        "external": false
                    });
                }

                const activeWg = new Set();

                for (const line of lines) {
                    if (!line.startsWith("wg\t"))
                        continue;

                    const [, iface] = line.split("\t");

                    if (!iface)
                        continue;

                    if (iface === "proton0") {
                        if (protonReady)
                            pConn = true;
                        else
                            pAct = true;

                        pServer = pServer || persistedServer;
                        continue;
                    }

                    activeWg.add(iface);
                }

                const wgConfs = new Set(activeWg);

                for (const line of lines) {
                    if (line.startsWith("wgconf\t"))
                        wgConfs.add(line.slice(7).trim());
                }

                for (const iface of wgConfs) {
                    if (nmDevices.has(iface) || nmNames.has(iface))
                        continue;

                    nmProfiles.push({
                        "id": "wg:" + iface,
                        "uuid": "",
                        "name": iface,
                        "kind": "wireguard",
                        "state": activeWg.has(iface) ? "activated" : "",
                        "connected": activeWg.has(iface),
                        "connecting": false,
                        "external": true
                    });
                }

                for (const line of lines) {
                    if (!line.startsWith("recent\t"))
                        continue;

                    const recent = line.slice(7).split(",").filter(c => /^[A-Z]{2}$/.test(c));
                    const merged = [...recent];

                    for (const code of root.defaultCountries) {
                        if (!merged.includes(code))
                            merged.push(code);
                    }

                    root.protonCountries = merged.slice(0, 6);
                }

                nmProfiles.sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name));
                root.protonConnected = pConn;
                root.protonActivating = pAct;
                root.protonServer = pServer;
                root.profiles = nmProfiles;
            }
        }
    }

    // qs ipc call vpn status   |   qs ipc call vpn toggle   |   qs ipc call vpn disconnect
    IpcHandler {
        target: "vpn"

        function status(): string {
            return root.connected ? root.activeConnections.join(", ") : "disconnected";
        }

        function toggle(): string {
            if (root.protonConnected || (root.hasProton && !root.connected && root.profiles.length === 0)) {
                root.toggleProton();
                return root.protonConnected ? "disconnecting" : "connecting";
            }

            const target = root.profiles.find(p => p.connected) ?? root.profiles[0];

            if (target) {
                root.toggleProfile(target);
                return target.connected ? "disconnecting" : "connecting";
            }

            if (root.hasProton) {
                root.toggleProton();
                return "connecting";
            }

            return "no vpn configured";
        }

        function disconnect(): void {
            if (root.protonConnected)
                root.toggleProton();

            for (const p of root.profiles.filter(p => p.connected))
                root.toggleProfile(p);
        }
    }
}
