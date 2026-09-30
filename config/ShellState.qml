pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Everything changeable from the dropdowns and settings page, persisted across restarts.
Singleton {
    id: root

    readonly property var keys: ["notificationsDnd", "theme", "fontFamily", "iconFontFamily", "fontSize", "iconSize", "hiddenModules", "clockSeconds", "clock24h", "weatherLocation", "popupSeconds", "popupMax", "osdEnabled", "workspaceLabels", "workspaceCustomLabels", "mutedApps"]

    property bool notificationsDnd: false

    property string theme: "nightfox"
    property string fontFamily: "IosevkaTermSlab Nerd Font"
    // Must contain the Nerd Font glyphs; services/Fonts.qml lists the installed candidates.
    property string iconFontFamily: "IosevkaTermSlab Nerd Font"
    property int fontSize: 15
    property int iconSize: 24
    // Bar module names (see modules/Bar.qml); reassign rather than mutate so bindings update.
    property var hiddenModules: []
    property bool clockSeconds: true
    property bool clock24h: true
    property string weatherLocation: "London"
    property int popupSeconds: 5
    property int popupMax: 5
    property bool osdEnabled: true
    // See config/WorkspaceLabels.qml; custom labels are comma-separated, one per workspace number.
    property string workspaceLabels: "numbers"
    property string workspaceCustomLabels: ""
    // App names whose notifications skip the popup but still land in history.
    property var mutedApps: []

    readonly property string timeFormat: (clock24h ? "HH" : "h") + ":mm" + (clockSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

    // Bar modules the settings page can hide, as [name, label].
    readonly property var modules: [["workspaces", "Workspaces"], ["media", "Media"], ["privacy", "Privacy indicator"], ["weather", "Weather"], ["clock", "Clock"], ["volume", "Volume"], ["cpu", "CPU"], ["ram", "RAM"], ["notifications", "Notifications"], ["network", "Network"], ["bluetooth", "Bluetooth"]]

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
