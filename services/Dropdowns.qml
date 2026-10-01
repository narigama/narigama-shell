pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which dropdown is open, on which screen, and where on the bar it hangs from.
Singleton {
    id: root

    property string current: ""
    property ShellScreen screen: null
    property real anchorX: 0
    // The bar item the open dropdown hangs from; it stays the anchor for pages reached from
    // within (e.g. settings from the system menu), so only that item shows as open.
    property Item anchorItem: null
    // Bar items that open each dropdown, keyed "<screen>/<dropdown>", so IPC can open them too.
    property var anchors: ({})

    function register(name, anchorItem, screen) {
        if (name !== "" && screen)
            anchors[screen.name + "/" + name] = anchorItem;
    }

    function toggle(name, anchorItem, screen) {
        if (current === name && root.screen === screen) {
            close();
            return;
        }

        root.anchorItem = anchorItem;
        anchorX = anchorItem.mapToItem(null, anchorItem.width / 2, 0).x;
        root.screen = screen;
        current = name;
    }

    function close() {
        current = "";
    }

    // qs ipc call dropdown toggle <name>            (focused monitor)
    // qs ipc call dropdown toggleOn <name> <monitor>
    IpcHandler {
        target: "dropdown"

        function toggle(name: string): string {
            return toggleOn(name, Compositor.focusedScreen()?.name ?? "");
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
}
