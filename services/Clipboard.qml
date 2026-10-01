pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// cliphist history. Needs `wl-paste --watch cliphist store` running (usually from the
// compositor's autostart) to record anything.
Singleton {
    id: root

    // False when nothing feeds cliphist, so the history never grows.
    property bool watching: true

    // [{ id, text, image }], newest first.
    property var entries: []
    readonly property int limit: 200

    function refresh() {
        listQuery.running = true;
        watchQuery.running = true;
    }

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", "cliphist decode '" + entry.id + "' | wl-copy"]);
    }

    function remove(entry) {
        entries = entries.filter(e => e.id !== entry.id);
        // `cliphist delete` takes the full list line on stdin.
        Quickshell.execDetached(["sh", "-c", "cliphist list | grep -m1 -P '^" + entry.id + "\\t' | cliphist delete"]);
    }

    function clear() {
        entries = [];
        Quickshell.execDetached(["cliphist", "wipe"]);
    }

    Process {
        id: watchQuery

        command: ["sh", "-c", "pgrep -f 'wl-paste.*--watch.*cliphist' >/dev/null && echo yes"]
        stdout: StdioCollector {
            onStreamFinished: root.watching = text.trim() === "yes"
        }
    }

    Process {
        id: listQuery

        command: ["sh", "-c", "cliphist list | head -n " + root.limit]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.split("\n").filter(l => l.includes("\t")).map(line => {
                const tab = line.indexOf("\t");
                const preview = line.slice(tab + 1);

                return {
                    "id": line.slice(0, tab),
                    "text": preview,
                    "image": /^\[\[ binary data .* \]\]$/.test(preview)
                };
            })
        }
    }
}
