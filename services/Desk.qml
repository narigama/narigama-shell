pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// External monitor brightness over DDC/CI (ddcutil), the idle inhibitor and gamemode state.
Singleton {
    id: root

    // [{ bus, screen (connector, e.g. "DP-3"), model }]. Only replaced on detection, so views
    // built from it (and a slider mid-drag) aren't recreated as brightness changes.
    property var displays: []
    // bus -> 0..100
    property var brightness: ({})
    property bool idleInhibited: false
    property bool gamemodeActive: false

    readonly property real averageBrightness: displays.length ? displays.reduce((sum, d) => sum + (brightness[d.bus] ?? 0), 0) / displays.length : 0

    // DDC writes take ~0.3s each, so only the latest value per display is queued.
    property var pendingBrightness: ({})

    function setBrightness(bus, value) {
        value = Math.round(Math.max(0, Math.min(100, value)));
        const levels = Object.assign({}, brightness);

        levels[bus] = value;
        brightness = levels;

        const pending = Object.assign({}, pendingBrightness);

        pending[bus] = value;
        pendingBrightness = pending;
        flushBrightness();
    }

    function setAllBrightness(value) {
        for (const display of displays)
            setBrightness(display.bus, value);
    }

    function flushBrightness() {
        if (setter.running)
            return;

        const buses = Object.keys(pendingBrightness);

        if (buses.length === 0)
            return;

        const pending = Object.assign({}, pendingBrightness);
        const commands = buses.map(bus => "ddcutil --bus " + bus + " --noverify setvcp 10 " + pending[bus] + " &").join(" ");

        pendingBrightness = {};
        setter.command = ["sh", "-c", commands + " wait"];
        setter.running = true;
    }

    function refresh() {
        if (Tools.has("ddcutil"))
            detect.running = true;
    }

    Connections {
        target: Tools

        function onReadyChanged() {
            root.refresh();
        }
    }

    Process {
        id: detect

        command: ["sh", "-c", "ddcutil detect --brief 2>/dev/null | awk '/I2C bus/{bus=$3; sub(\"/dev/i2c-\",\"\",bus)} /DRM connector/{conn=$3; sub(\"^card[0-9]+-\",\"\",conn)} /Monitor:/{print bus\"\\t\"conn\"\\t\"$2}' | while IFS=\"$(printf '\\t')\" read bus conn model; do printf '%s\\t%s\\t%s\\t%s\\n' \"$bus\" \"$conn\" \"$model\" \"$(ddcutil --bus $bus getvcp 10 --brief 2>/dev/null | awk '{print $4}')\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n").filter(l => l !== "").map(line => line.split("\t")).filter(r => r[0] !== "");
                const levels = {};

                for (const [bus, , , level] of rows)
                    levels[bus] = Number(level) || 0;

                root.brightness = levels;
                root.displays = rows.map(([bus, screen, model]) => ({
                            "bus": bus,
                            "screen": screen,
                            "model": model.split(":").slice(1, 2).join("")
                        }));
            }
        }
    }

    Process {
        id: setter

        onExited: root.flushBrightness()
    }

    Timer {
        interval: 5000
        running: Tools.has("gamemoded")
        repeat: true
        triggeredOnStart: true
        onTriggered: gamemode.running = true
    }

    Process {
        id: gamemode

        command: ["gamemoded", "-s"]
        stdout: StdioCollector {
            onStreamFinished: root.gamemodeActive = text.includes("is active")
        }
    }
}
