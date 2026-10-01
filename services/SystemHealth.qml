pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Disk usage, pending package updates and failed systemd units.
Singleton {
    id: root

    // [{ mount, size, used, avail (bytes) }], root filesystem first.
    property var disks: []
    readonly property var rootDisk: disks.find(d => d.mount === "/") ?? null
    readonly property real rootPercent: rootDisk ? 100 * rootDisk.used / Math.max(1, rootDisk.size) : 0

    // [{ name, from, to, aur }]
    property var updates: []
    property bool checkingUpdates: false
    property double updatesCheckedAt: 0

    // [{ unit, description, user }]
    property var failedUnits: []

    function formatBytes(bytes) {
        const units = ["B", "KiB", "MiB", "GiB", "TiB"];
        let value = bytes;
        let unit = 0;

        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024;
            unit++;
        }

        return value.toFixed(unit >= 3 ? 1 : 0) + " " + units[unit];
    }

    function refreshDisks() {
        diskQuery.running = true;
    }

    function checkUpdates() {
        if (checkingUpdates || !Tools.ready || !Tools.available("updates"))
            return;

        checkingUpdates = true;
        updatesQuery.running = true;
    }

    function refreshFailedUnits() {
        failedQuery.running = true;
    }

    function runUpdate() {
        Quickshell.execDetached(Tools.terminalCommand.concat(["sh", "-c", updateCommands[Tools.packageManager] + "; echo; read -p 'Press enter to close' _"]));
    }

    function showUnitStatus(unit) {
        const scope = unit.user ? "--user " : "";

        Quickshell.execDetached(Tools.terminalCommand.concat(["sh", "-c", "systemctl " + scope + "status --no-pager -l '" + unit.unit + "'; echo; journalctl " + scope + "-u '" + unit.unit + "' -n 30 --no-pager; read -p 'Press enter to close' _"]));
    }

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshDisks();
            root.refreshFailedUnits();
        }
    }

    Timer {
        interval: Config.updatesRefreshMs
        running: Tools.ready
        repeat: true
        triggeredOnStart: true
        onTriggered: root.checkUpdates()
    }

    Process {
        id: diskQuery

        command: ["df", "-B1", "--output=target,size,used,avail", "-x", "tmpfs", "-x", "devtmpfs", "-x", "efivarfs", "-x", "overlay", "-x", "squashfs"]
        stdout: StdioCollector {
            onStreamFinished: {
                const disks = text.trim().split("\n").slice(1).map(line => {
                    const fields = line.trim().split(/\s+/);
                    const [size, used, avail] = fields.slice(-3).map(Number);

                    return {
                        "mount": fields.slice(0, -3).join(" "),
                        "size": size,
                        "used": used,
                        "avail": avail
                    };
                }).filter(d => d.size > 0);

                root.disks = disks.sort((a, b) => (a.mount === "/" ? -1 : b.mount === "/" ? 1 : a.mount.localeCompare(b.mount)));
            }
        }
    }

    // Each backend prints "<repo|aur> <name> <from|-> <to>" lines.
    // pacman: like pacman-contrib's checkupdates, syncs a private copy of the sync databases with
    // fakeroot so the system's own are never partially upgraded. apt: reads the cache from the last
    // `apt update` (refreshing needs root). dnf: refreshes its per-user metadata cache itself.
    readonly property var updateQueries: ({
            "pacman": `
                db="\${XDG_CACHE_HOME:-$HOME/.cache}/narigama-shell/pacman-db"
                mkdir -p "$db"
                ln -sfn /var/lib/pacman/local "$db/local"
                fakeroot -- pacman -Sy --disable-sandbox --dbpath "$db" --logfile /dev/null >/dev/null 2>&1
                pacman -Qu --dbpath "$db" 2>/dev/null | grep -v '\\[ignored\\]' | awk '{print "repo", $1, $2, $4}'
                for helper in paru yay; do
                    if command -v $helper >/dev/null; then $helper -Qua 2>/dev/null | grep -v '\\[ignored\\]' | awk '{print "aur", $1, $2, $4}'; break; fi
                done
                true`,
            "apt": `apt list --upgradable 2>/dev/null | awk -F'[ /]' 'NR > 1 && NF >= 4 {from = $NF; sub(/]$/, "", from); print "repo", $1, from, $3}'`,
            "dnf": `dnf -q check-update 2>/dev/null | awk '/^Obsoleting/ {exit} NF == 3 && $1 ~ /\\./ {name = $1; sub(/\\.[^.]+$/, "", name); print "repo", name, "-", $2}'`
        })
    readonly property var updateCommands: ({
            "pacman": Tools.aurHelper !== "" ? Tools.aurHelper : "sudo pacman -Syu",
            "apt": "sudo apt update && sudo apt upgrade",
            "dnf": "sudo dnf upgrade"
        })

    Process {
        id: updatesQuery

        command: ["sh", "-c", root.updateQueries[Tools.packageManager] ?? "true"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.updates = text.trim().split("\n").filter(l => l.split(" ").length >= 4).map(line => {
                    const [source, name, from, to] = line.split(" ");

                    return {
                        "name": name,
                        "from": from === "-" ? "" : from,
                        "to": to,
                        "aur": source === "aur"
                    };
                });
                root.checkingUpdates = false;
                root.updatesCheckedAt = Date.now();
            }
        }
    }

    Process {
        id: failedQuery

        command: ["sh", "-c", "systemctl --failed --no-legend --plain | sed 's/^/system /'; systemctl --user --failed --no-legend --plain | sed 's/^/user /'"]
        stdout: StdioCollector {
            onStreamFinished: root.failedUnits = text.trim().split("\n").filter(l => l !== "").map(line => {
                const [scope, unit, , , , ...description] = line.split(/\s+/);

                return {
                    "unit": unit,
                    "description": description.join(" "),
                    "user": scope === "user"
                };
            })
        }
    }
}
