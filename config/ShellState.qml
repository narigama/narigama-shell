pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Everything changeable from the dropdowns and settings page, persisted across restarts.
Singleton {
    id: root

    readonly property var keys: ["notificationsDnd", "theme", "fontFamily", "iconFontFamily", "fontSize", "iconSize", "hiddenModules", "clockSeconds", "clock24h", "weatherLocation", "popupSeconds", "popupMax", "osdEnabled", "workspaceLabels", "workspaceCustomLabels", "mutedApps", "barPosition", "popupPosition", "barLayout", "captureAnnotate", "captureAudio", "wallpaper", "wallpaperDir", "matchWallpaper", "wallpaperThemeMode", "wallpaperColors"]

    property bool notificationsDnd: false

    property string theme: "nightfox"
    property string fontFamily: "IosevkaTermSlab Nerd Font"
    // Must contain the Nerd Font glyphs; config/Fonts.qml lists the installed candidates; Theme falls back if it is missing.
    property string iconFontFamily: "IosevkaTermSlab Nerd Font"
    property int fontSize: 15
    property int iconSize: 24
    // Bar module names (see modules/Bar.qml); reassign rather than mutate so bindings update.
    // Extras start hidden; they can be switched on in settings.
    property var hiddenModules: ["capture", "idleInhibit", "colorPicker", "clipboard", "failedUnits", "brightness", "updates", "gamemode"]
    property bool clockSeconds: true
    property bool clock24h: true
    // Empty until set; the weather module stays hidden meanwhile.
    property string weatherLocation: ""
    property int popupSeconds: 5
    property int popupMax: 5
    property bool osdEnabled: true
    // See config/WorkspaceLabels.qml; custom labels are comma-separated, one per workspace number.
    property string workspaceLabels: "numbers"
    property string workspaceCustomLabels: ""
    // App names whose notifications skip the popup but still land in history.
    property var mutedApps: []
    // "top" or "bottom".
    property string barPosition: "top"
    readonly property bool barAtBottom: barPosition === "bottom"
    // "<top|bottom>-<left|center|right>".
    property string popupPosition: "bottom-right"

    readonly property string timeFormat: (clock24h ? "HH" : "h") + ":mm" + (clockSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

    // Bar modules the settings page can hide, as [name, label].
    readonly property var modules: [["workspaces", "Workspaces"], ["media", "Media"], ["privacy", "Privacy indicator"], ["weather", "Weather"], ["clock", "Clock"], ["volume", "Volume"], ["cpu", "CPU"], ["ram", "RAM"], ["notifications", "Notifications"], ["network", "Network"], ["bluetooth", "Bluetooth"], ["dashboard", "System menu"], ["disk", "Disk usage"], ["updates", "Package updates"], ["failedUnits", "Failed units"], ["capture", "Screenshot and recording"], ["clipboard", "Clipboard history"], ["colorPicker", "Colour picker"], ["brightness", "Monitor brightness"], ["idleInhibit", "Idle inhibitor"], ["gamemode", "Gamemode"]]
    // The system menu holds settings, so it can be moved but never hidden.
    readonly property var unhideableModules: ["dashboard"]

    // Module order per bar group. Saved as-is; read through `layout`, which repairs it.
    readonly property var defaultLayout: ({
            "left": ["workspaces"],
            "center": ["media"],
            "right": ["privacy", "weather", "clock", "volume", "brightness", "disk", "cpu", "ram", "notifications", "failedUnits", "gamemode", "updates", "clipboard", "colorPicker", "capture", "idleInhibit", "network", "bluetooth", "dashboard"]
        })
    property var barLayout: defaultLayout
    // Screenshots open in satty; recordings include audio.
    property bool captureAnnotate: false
    property bool captureAudio: false

    property string wallpaper: ""
    // Empty means the default: the XDG Pictures folder plus /Wallpapers (see Wallpapers.folder).
    property string wallpaperDir: ""
    // Replaces the theme's colours with a palette matugen derives from the wallpaper.
    property bool matchWallpaper: false
    // "dark" or "light"
    property string wallpaperThemeMode: "dark"
    property var wallpaperColors: null
    // Every known module exactly once: unknown names dropped, missing ones (e.g. added in a later
    // version) placed after their predecessor in the default layout.
    readonly property var layout: {
        const known = modules.map(m => m[0]);
        const seen = [];
        const out = {
            "left": [],
            "center": [],
            "right": []
        };

        for (const group of ["left", "center", "right"]) {
            for (const name of barLayout?.[group] ?? []) {
                if (known.includes(name) && !seen.includes(name)) {
                    out[group].push(name);
                    seen.push(name);
                }
            }
        }

        for (const group of ["left", "center", "right"]) {
            const defaults = defaultLayout[group];

            defaults.forEach((name, i) => {
                if (seen.includes(name))
                    return;

                const before = defaults.slice(0, i).reverse().find(n => seen.includes(n));
                const target = before ? ["left", "center", "right"].find(g => out[g].includes(before)) : group;
                const at = before ? out[target].indexOf(before) + 1 : 0;

                out[target].splice(at, 0, name);
                seen.push(name);
            });
        }

        return out;
    }

    function moduleLabel(name) {
        return (modules.find(m => m[0] === name) ?? [name, name])[1];
    }

    function moveModule(name, group, index) {
        const next = {
            "left": layout.left.filter(n => n !== name),
            "center": layout.center.filter(n => n !== name),
            "right": layout.right.filter(n => n !== name)
        };

        next[group].splice(Math.max(0, Math.min(index, next[group].length)), 0, name);
        barLayout = next;
    }

    function moduleVisible(name) {
        return !hiddenModules.includes(name);
    }

    function setModuleVisible(name, visible) {
        hiddenModules = visible ? hiddenModules.filter(m => m !== name) : hiddenModules.concat([name]);
    }

    // Guards against overwriting the file with defaults before it has been read.
    property bool loaded: false

    function save() {
        if (!loaded)
            return;

        const data = {};

        for (const key of keys)
            data[key] = root[key];

        file.setText(JSON.stringify(data, null, 2));
    }

    onNotificationsDndChanged: save()
    onThemeChanged: save()
    onFontFamilyChanged: save()
    onIconFontFamilyChanged: save()
    onFontSizeChanged: save()
    onIconSizeChanged: save()
    onHiddenModulesChanged: save()
    onClockSecondsChanged: save()
    onClock24hChanged: save()
    onWeatherLocationChanged: save()
    onPopupSecondsChanged: save()
    onPopupMaxChanged: save()
    onOsdEnabledChanged: save()
    onWorkspaceLabelsChanged: save()
    onWorkspaceCustomLabelsChanged: save()
    onMutedAppsChanged: save()
    onBarPositionChanged: save()
    onPopupPositionChanged: save()
    onBarLayoutChanged: save()
    onCaptureAnnotateChanged: save()
    onCaptureAudioChanged: save()
    onWallpaperChanged: save()
    onWallpaperDirChanged: save()
    onMatchWallpaperChanged: save()
    onWallpaperThemeModeChanged: save()
    onWallpaperColorsChanged: save()

    // qs ipc call settings get <key>   |   qs ipc call settings set <key> <json value>
    // The qs CLI swallows arguments starting with "[", so prefix arrays with a space: ' []'.
    IpcHandler {
        target: "settings"

        function get(key: string): string {
            return root.keys.includes(key) ? JSON.stringify(root[key]) : "unknown setting " + key;
        }

        function set(key: string, value: string): string {
            if (!root.keys.includes(key))
                return "unknown setting " + key;

            try {
                root[key] = JSON.parse(value);
            } catch (e) {
                return "value must be JSON, e.g. '\"Adwaita Sans\"' or 16";
            }

            return JSON.stringify(root[key]);
        }
    }

    // qs ipc call theme set <id>   |   qs ipc call theme list
    IpcHandler {
        target: "theme"

        function set(id: string): string {
            if (!Themes.list.some(t => t.id === id))
                return "unknown theme " + id;

            root.theme = id;

            return id;
        }

        function list(): string {
            return Themes.list.map(t => t.id).join("\n");
        }
    }

    FileView {
        id: file

        path: Quickshell.statePath("state.json")
        blockLoading: true
        printErrors: false

        onLoaded: {
            try {
                const data = JSON.parse(text());

                for (const key of root.keys) {
                    if (key in data)
                        root[key] = data[key];
                }
            } catch (e) {
                console.warn("Ignoring unreadable state.json:", e);
            }

            root.loaded = true;
        }

        onLoadFailed: root.loaded = true
    }
}
