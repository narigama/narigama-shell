pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Built-in screen and keyboard backlights through brightnessctl, which writes via logind, so no
// root or udev rule is needed.
Singleton {
    id: root

    // { device, level, max }, or null when there's no such backlight.
    property var screen: null
    property var keyboard: null
    readonly property real screenFraction: screen ? screen.level / screen.max : 0
    readonly property real keyboardFraction: keyboard ? keyboard.level / keyboard.max : 0
    // device -> level, written once the running brightnessctl finishes.
    property var pending: ({})

    function refresh() {
        if (Tools.has("brightnessctl"))
            list.running = true;
    }

    // Never fully off: a 0 backlight leaves the screen black.
    function setScreen(fraction) {
        if (!screen)
            return;

        screen = Object.assign({}, screen, {
            "level": Math.max(1, Math.min(screen.max, Math.round(fraction * screen.max)))
        });
        write(screen.device, screen.level);
    }

    function setKeyboard(level) {
        if (!keyboard)
            return;

        keyboard = Object.assign({}, keyboard, {
            "level": Math.max(0, Math.min(keyboard.max, Math.round(level)))
        });
        write(keyboard.device, keyboard.level);
    }

    function stepScreen(delta) {
        setScreen(screenFraction + delta);

        if (screen)
            Osd.show(Icons.brightness, Math.round(screenFraction * 100) + "%", screenFraction, Theme.yellow);
    }

    // Keyboards usually have a few fixed levels; finer ones step by 10%.
    function stepKeyboard(direction) {
        if (!keyboard)
            return;

        setKeyboard(keyboard.level + direction * (keyboard.max <= 10 ? 1 : Math.ceil(keyboard.max / 10)));
        Osd.show(Icons.keyboard, "Keyboard " + Math.round(keyboardFraction * 100) + "%", keyboardFraction, Theme.yellow);
    }

    function write(device, level) {
        const next = Object.assign({}, pending);

        next[device] = level;
        pending = next;
        flush();
    }

    function flush() {
        if (setter.running)
            return;

        const devices = Object.keys(pending);

        if (devices.length === 0)
            return;

        setter.command = ["sh", "-c", devices.map(d => "brightnessctl -q -d '" + d + "' set " + pending[d]).join("; ")];
        pending = {};
        setter.running = true;
    }

    Connections {
        target: Tools

        function onReadyChanged() {
            root.refresh();
        }
    }

    // Lines of "device,class,level,percent,max".
    Process {
        id: list

        command: ["brightnessctl", "-m", "-l"]
        stdout: StdioCollector {
            onStreamFinished: {
                const devices = text.trim().split("\n").filter(l => l !== "").map(l => l.split(",")).map(f => ({
                            "device": f[0],
                            "kind": f[1],
                            "level": Number(f[2]),
                            "max": Number(f[4])
                        })).filter(d => d.max > 0);
                const screen = devices.find(d => d.kind === "backlight");
                const keyboard = devices.find(d => d.kind === "leds" && d.device.includes("kbd_backlight"));

                root.screen = screen ? {
                    "device": screen.device,
                    "level": screen.level,
                    "max": screen.max
                } : null;
                root.keyboard = keyboard ? {
                    "device": keyboard.device,
                    "level": keyboard.level,
                    "max": keyboard.max
                } : null;
            }
        }
    }

    Process {
        id: setter

        onExited: root.flush()
    }

    // qs ipc call backlight up|down|keyboardUp|keyboardDown   (bind to the brightness keys)
    IpcHandler {
        target: "backlight"

        function up(): void {
            root.stepScreen(0.05);
        }

        function down(): void {
            root.stepScreen(-0.05);
        }

        function keyboardUp(): void {
            root.stepKeyboard(1);
        }

        function keyboardDown(): void {
            root.stepKeyboard(-1);
        }
    }
}
