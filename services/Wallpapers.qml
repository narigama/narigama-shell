pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Wallpapers from `folder`, applied with awww (falling back to swaybg), with cached
// thumbnails and an optional palette derived from the wallpaper by matugen.
Singleton {
    id: root

    // [{ path, name, thumb }], sorted by name.
    property var wallpapers: []
    readonly property string folder: ShellState.wallpaperDir || Tools.picturesDir + "/Wallpapers"
    property bool scanning: false
    // screen name -> path currently shown (awww only; swaybg can't be queried).
    property var current: ({})
    property bool generating: false
    // Fastest monitor refresh rate; awww animates transitions at 30fps unless told otherwise.
    property int transitionFps: 60

    readonly property string backend: Tools.has("awww") ? "awww" : Tools.has("swaybg") ? "swaybg" : ""
    readonly property string thumbDir: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/narigama-shell/thumbnails"

    function scan() {
        if (scanning || !Tools.ready || !Tools.available("wallpapers"))
            return;

        scanning = true;
        scanQuery.running = true;
        refreshQuery.running = true;
        currentQuery.running = backend === "awww";
    }

    function isCurrent(path) {
        return Object.values(current).includes(path) || (backend !== "awww" && ShellState.wallpaper === path);
    }

    // `screens` is a list of screen names; empty means every screen.
    function apply(path, screens) {
        if (backend === "awww") {
            const outputs = screens.length ? ["--outputs", screens.join(",")] : [];

            Quickshell.execDetached(["awww", "img", path, "--transition-type", "wipe", "--transition-angle", "30", "--transition-duration", "1", "--transition-fps", String(transitionFps)].concat(outputs));

            const next = Object.assign({}, current);

            for (const screen of screens.length ? screens : Quickshell.screens.map(s => s.name))
                next[screen] = path;

            current = next;
        } else if (backend === "swaybg") {
            // swaybg has no IPC: replace the running instance, one output flag per target.
            const outputs = screens.length ? screens.map(s => "-o '" + s + "' -i '" + path + "' -m fill").join(" ") : "-i '" + path + "' -m fill";

            Quickshell.execDetached(["sh", "-c", "pkill -x swaybg; exec swaybg " + outputs]);
        }

        ShellState.wallpaper = path;

        if (ShellState.matchWallpaper)
            generatePalette(path);
    }

    function generatePalette(path) {
        if (!Tools.has("matugen") || path === "")
            return;

        generating = true;
        palette.command = ["matugen", "image", path, "--json", "hex", "--dry-run", "--prefer", "saturation", "-m", ShellState.wallpaperThemeMode];
        palette.running = true;
    }

    Connections {
        target: Tools

        function onReadyChanged() {
            root.scan();
        }
    }

    Connections {
        target: ShellState

        function onWallpaperDirChanged() {
            root.scan();
        }

        function onMatchWallpaperChanged() {
            if (ShellState.matchWallpaper)
                root.generatePalette(ShellState.wallpaper);
        }

        function onWallpaperThemeModeChanged() {
            if (ShellState.matchWallpaper)
                root.generatePalette(ShellState.wallpaper);
        }
    }

    // Lists images and makes any missing 480px-wide thumbnails (named by a hash of the path).
    Process {
        id: scanQuery

        command: ["sh", "-c", `
            dir="$1"; thumbs="$2"
            mkdir -p "$thumbs"
            find "$dir" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort | while read -r file; do
                thumb="$thumbs/$(printf '%s' "$file" | md5sum | cut -c1-32).jpg"
                if [ ! -s "$thumb" ] || [ "$file" -nt "$thumb" ]; then
                    if command -v vipsthumbnail >/dev/null; then
                        vipsthumbnail "$file" --size 480x -o "$thumb[Q=85]" 2>/dev/null
                    else
                        magick "$file[0]" -thumbnail 480x "$thumb" 2>/dev/null
                    fi
                fi
                printf '%s\\t%s\\n' "$file" "$thumb"
            done`, "sh", root.folder, root.thumbDir]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.split("\n").filter(l => l.includes("\t")).map(line => {
                    const [path, thumb] = line.split("\t");

                    return {
                        "path": path,
                        "name": path.split("/").pop(),
                        "thumb": thumb
                    };
                });
                root.scanning = false;
            }
        }
    }

    // Integer Hz per output from whichever compositor is running; the highest wins.
    Process {
        id: refreshQuery

        command: ["sh", "-c", `
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then hyprctl monitors -j | grep -o '"refreshRate": [0-9.]*' | grep -o '[0-9.]*$'
            elif [ -n "$SWAYSOCK" ]; then swaymsg -t get_outputs -r | grep -o '"refresh": [0-9]*' | awk '{print $2 / 1000}'
            elif [ -n "$NIRI_SOCKET" ]; then niri msg -j outputs | grep -o '"refresh_rate": [0-9]*' | awk '{print $2 / 1000}'
            fi 2>/dev/null`]
        stdout: StdioCollector {
            onStreamFinished: {
                const rates = text.split("\n").map(Number).filter(r => r > 0);

                root.transitionFps = rates.length ? Math.round(Math.max(...rates)) : 60;
            }
        }
    }

    Process {
        id: currentQuery

        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const next = {};

                for (const line of text.split("\n")) {
                    const match = line.match(/^:?\s*([^:]+):.*image:\s*(.+)$/);

                    if (match)
                        next[match[1].trim()] = match[2].trim();
                }

                root.current = next;
            }
        }
    }

    // Maps Material You roles onto the shell's palette. The accent slots take the wallpaper's
    // roles rather than literal hues, so "green" or "blue" follow the image.
    Process {
        id: palette

        stdout: StdioCollector {
            onStreamFinished: {
                root.generating = false;

                try {
                    const data = JSON.parse(text);
                    const mode = ShellState.wallpaperThemeMode;
                    const role = name => data.colors[name][mode].color;

                    ShellState.wallpaperColors = {
                        "bg": role("surface"),
                        "surface": role("surface_container"),
                        "elevated": role("surface_container_highest"),
                        "fg": role("on_surface"),
                        "fgMuted": role("on_surface_variant"),
                        "fgSubtle": role("outline"),
                        "primary": role("primary"),
                        "red": role("error"),
                        "yellow": role("tertiary"),
                        "green": role("secondary"),
                        "blue": role(mode === "dark" ? "primary_fixed_dim" : "on_primary_container")
                    };
                } catch (e) {
                    console.warn("matugen output unreadable:", e);
                }
            }
        }
    }
}
