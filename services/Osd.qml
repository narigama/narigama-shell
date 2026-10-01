pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import qs.config

// On-screen display: watches audio, media, devices and settings, and shows a short popup
// for each change. Hardware keys only change state (wpctl/playerctl); this reacts to it.
Singleton {
    id: root

    property bool shown: false
    property string icon
    property string label
    // 0..1 draws a level bar; negative hides it.
    property real value: -1
    property color accent: Theme.primary

    // Ignore the burst of "changes" while services first report their state.
    property bool armed: false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property var connectedBluetooth: Bluetooth.devices.values.filter(d => d.connected).map(d => d.name)
    property var lastBluetooth: []

    readonly property string networkName: {
        const devices = Networking.devices.values;
        const wired = devices.find(d => d.type === DeviceType.Wired && d.connected);

        if (wired)
            return "Wired (" + wired.name + ")";

        const wifi = devices.find(d => d.type === DeviceType.Wifi);
        const network = wifi?.networks.values.find(n => n.connected);

        return network?.name ?? "";
    }
    property string lastNetwork: ""

    property string lastLayout: ""

    function show(icon, label, value, accent) {
        if (!armed || !ShellState.osdEnabled)
            return;

        root.icon = icon;
        root.label = label;
        root.value = value ?? -1;
        root.accent = accent ?? Theme.primary;
        shown = true;
        hideTimer.restart();
    }

    function showVolume() {
        const audio = sink?.audio;

        if (audio)
            show(Icons.forVolume(audio.volume, audio.muted), audio.muted ? "Muted" : Math.round(audio.volume * 100) + "%", audio.muted ? 0 : audio.volume, Theme.red);
    }

    function showMic() {
        const audio = source?.audio;

        if (audio)
            show(audio.muted ? Icons.microphoneOff : Icons.microphone, audio.muted ? "Mic muted" : "Mic " + Math.round(audio.volume * 100) + "%", audio.muted ? 0 : audio.volume, Theme.yellow);
    }

    Timer {
        interval: 2500
        running: true
        onTriggered: {
            root.lastBluetooth = root.connectedBluetooth;
            root.lastNetwork = root.networkName;
            root.armed = true;
        }
    }

    Timer {
        id: hideTimer

        interval: 1500
        onTriggered: root.shown = false
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() {
            root.showVolume();
        }

        function onMutedChanged() {
            root.showVolume();
        }
    }

    Connections {
        target: root.source?.audio ?? null

        function onVolumeChanged() {
            root.showMic();
        }

        function onMutedChanged() {
            root.showMic();
        }
    }

    onSinkChanged: {
        if (sink)
            show(Icons.speaker, sink.description || sink.nickname || sink.name, -1, Theme.red);
    }

    onSourceChanged: {
        if (source)
            show(Icons.microphone, source.description || source.nickname || source.name, -1, Theme.yellow);
    }

    Connections {
        target: ShellState

        function onNotificationsDndChanged() {
            root.show(ShellState.notificationsDnd ? Icons.bellOff : Icons.bell, ShellState.notificationsDnd ? "Do not disturb" : "Notifications on", -1, Theme.green);
        }

        function onThemeChanged() {
            root.show(Icons.palette, Themes.find(ShellState.theme).name, -1, Theme.primary);
        }
    }

    onConnectedBluetoothChanged: {
        if (!armed)
            return;

        const added = connectedBluetooth.filter(n => !lastBluetooth.includes(n));
        const removed = lastBluetooth.filter(n => !connectedBluetooth.includes(n));

        if (added.length > 0)
            show(Icons.bluetoothConnect, added.join(", ") + " connected", -1, Theme.blue);
        else if (removed.length > 0)
            show(Icons.bluetoothOff, removed.join(", ") + " disconnected", -1, Theme.fgMuted);

        lastBluetooth = connectedBluetooth;
    }

    onNetworkNameChanged: {
        if (!armed || networkName === lastNetwork)
            return;

        if (networkName !== "")
            show(networkName.startsWith("Wired") ? Icons.ethernet : Icons.wifiStrength[3], "Connected to " + networkName, -1, Theme.primary);
        else
            show(Icons.lanDisconnect, "Disconnected", -1, Theme.fgMuted);

        lastNetwork = networkName;
    }

    // Compositors report the layout once per keyboard, so repeats are dropped.
    Connections {
        target: Compositor

        function onKeyboardLayoutChanged(layout) {
            if (layout === root.lastLayout)
                return;

            root.lastLayout = layout;
            root.show(Icons.keyboard, layout, -1, Theme.primary);
        }
    }

    Process {
        id: capsQuery

        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const keyboards = JSON.parse(text).keyboards ?? [];
                const main = keyboards.find(k => k.main) ?? keyboards[0];

                if (main)
                    root.show(Icons.capsLock, main.capsLock ? "Caps Lock on" : "Caps Lock off", -1, main.capsLock ? Theme.yellow : Theme.fgMuted);
            }
        }
    }

    // qs ipc call osd capsLock   (bind to Caps_Lock; Hyprland has no caps-lock event)
    // qs ipc call osd message <text>
    IpcHandler {
        target: "osd"

        // Only Hyprland exposes the caps lock state (via hyprctl).
        function capsLock(): void {
            if (Compositor.hasCapsLock)
                capsQuery.running = true;
        }

        function message(text: string): void {
            root.show(Icons.application, text, -1, Theme.primary);
        }
    }
}
