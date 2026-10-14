pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Which dropdown is open, on which screen, and where on the bar it hangs from.
Singleton {
    id: root

    property string current: ""
    // When `current` last changed, for telling a real outside click from a hand-over.
    property double changedAt: 0
    property ShellScreen screen: null
    property real anchorX: 0
    // The bar item the open dropdown hangs from; it stays the anchor for pages reached from
    // within (e.g. settings from the system menu), so only that item shows as open.
    property Item anchorItem: null
    // Centred on the display rather than hanging from the bar.
    property bool floating: false
    // Bar items that open each dropdown, keyed "<screen>/<dropdown>", so IPC can open them too.
    property var anchors: ({})

    function register(name, anchorItem, screen) {
        if (name !== "" && screen)
            anchors[screen.name + "/" + name] = anchorItem;
    }

    // Without an anchorItem, `position` ("left", "center", "right" or "floating") places it instead.
    function toggle(name, anchorItem, screen, position = "center") {
        if (current === name && root.screen === screen) {
            close();
            return;
        }

        root.anchorItem = anchorItem;
        floating = !anchorItem && position === "floating";
        // The host clamps x to the screen, so 0 and the full width pin it to either edge.
        anchorX = anchorItem ? anchorItem.mapToItem(null, anchorItem.width / 2, 0).x : position === "left" ? 0 : position === "right" ? screen.width : screen.width / 2;
        root.screen = screen;
        current = name;
    }

    // Toggles on the focused monitor, from the bar item registered there, or placed at `position`
    // (see toggle) without one, e.g. the launcher bound to a key.
    function toggleFocused(name, position = "") {
        const screenName = Compositor.focusedScreen()?.name ?? "";
        const anchorItem = position ? null : anchors[screenName + "/" + name] ?? null;
        const screen = Quickshell.screens.find(s => s.name === screenName);

        if (!screen || (!anchorItem && !position))
            return "no dropdown '" + name + "' on " + screenName;

        toggle(name, anchorItem, screen, position);

        return current;
    }

    onCurrentChanged: changedAt = Date.now()

    function close() {
        current = "";
    }

    // qs ipc call dropdown toggle <name>            (focused monitor)
    // qs ipc call dropdown toggleOn <name> <monitor>
    IpcHandler {
        target: "dropdown"

        function toggle(name: string): string {
            return root.toggleFocused(name);
        }

        function toggleOn(name: string, screenName: string): string {
            const screen = Quickshell.screens.find(s => s.name === screenName);
            const anchorItem = root.anchors[screenName + "/" + name];

            if (!screen || !anchorItem)
                return "no dropdown '" + name + "' on " + screenName;

            root.toggle(name, anchorItem, screen);

            return root.current;
        }

        function close(): void {
            root.close();
        }
    }

    // qs ipc call launcher toggle   (focused monitor, at ShellState.launcherPosition). Lives here because this service always runs.
    IpcHandler {
        target: "launcher"

        function toggle(): string {
            return root.toggleFocused("launcher", ShellState.launcherPosition);
        }
    }
}
