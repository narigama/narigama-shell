pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import Quickshell.Io
import Quickshell.WindowManager

// One interface over the compositor's workspaces and focus, so the rest of the shell doesn't
// care which compositor it's running under. Backends:
//   "hyprland": Quickshell.Hyprland (full support)
//   "i3":       Quickshell.I3 for Sway and i3
//   "ext":      Quickshell.WindowManager, i.e. the ext-workspace-v1 protocol (niri, labwc, Jay)
// Workspace objects are the backend's own (HyprlandWorkspace, I3Workspace, Windowset); always
// go through the functions here rather than reading their properties directly.
// Each backend singleton is only touched in its own branch, so the others never try to connect.
Singleton {
    id: root

    readonly property string backend: {
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
            return "hyprland";

        if (Quickshell.env("SWAYSOCK") || Quickshell.env("I3SOCK"))
            return "i3";

        return "ext";
    }

    readonly property bool isHyprland: backend === "hyprland"
    readonly property bool isI3: backend === "i3"
    readonly property bool isExt: backend === "ext"

    // Features only some backends can provide; callers hide or skip the rest.
    readonly property bool hasFocusGrab: isHyprland
    readonly property bool hasWindowLists: isHyprland
    readonly property bool hasCapsLock: isHyprland

    readonly property var workspaces: {
        if (isHyprland)
            return Hyprland.workspaces.values.slice().sort((a, b) => a.id - b.id);

        if (isI3)
            return I3.workspaces.values.slice().sort((a, b) => a.number - b.number);

        return WindowManager.windowsets.filter(w => w.shouldDisplay).sort((a, b) => extOrder(a) - extOrder(b));
    }

    // Empty when the backend can't tell (ext-workspace has no focus); callers fall back to the first screen.
    readonly property string focusedScreenName: {
        if (isHyprland)
            return Hyprland.focusedMonitor?.name ?? "";

        if (isI3)
            return I3.focusedMonitor?.name ?? "";

        return "";
    }

    signal keyboardLayoutChanged(string layout)

    // ext-workspace coordinates are a list (niri: [0, index]); the last entry orders within an output.
    function extOrder(windowset) {
        const coordinates = windowset.coordinates;

        return Array.isArray(coordinates) ? (coordinates[coordinates.length - 1] ?? 0) : Number(coordinates) || 0;
    }

    function workspacesFor(screen) {
        return workspaces.filter(w => screenName(w) === screen.name);
    }

    function screenName(workspace) {
        if (isExt)
            return workspace.projection?.screens[0]?.name ?? "";

        return workspace.monitor?.name ?? "";
    }

    function focusedScreen() {
        return Quickshell.screens.find(s => s.name === focusedScreenName) ?? Quickshell.screens[0] ?? null;
    }

    // Visible on its own screen.
    function isActive(workspace) {
        return workspace.active;
    }

    // Has keyboard focus; ext-workspace can't tell, so the active one stands in.
    function isFocused(workspace) {
        return isExt ? workspace.active : workspace.focused;
    }

    // A window on it asked for attention (bell, xdg-activation); clears once visited.
    function isUrgent(workspace) {
        return workspace.urgent;
    }

    function isOccupied(workspace) {
        return isHyprland ? workspace.toplevels.values.length > 0 : true;
    }

    function activate(workspace) {
        workspace.activate();
    }

    // Workspace number, or 0 for named and special workspaces, which keep their names.
    function number(workspace) {
        if (isHyprland)
            return workspace.id > 0 && String(workspace.id) === workspace.name ? workspace.id : 0;

        if (isI3)
            return workspace.number > 0 && String(workspace.number) === workspace.name ? workspace.number : 0;

        return /^\d+$/.test(workspace.name) ? Number(workspace.name) : 0;
    }

    function name(workspace) {
        return workspace.name.replace(/^special:/, "");
    }

    // [{ title, subtitle, focused, focus() }]; empty where the compositor can't list windows per workspace.
    function windowsFor(workspace) {
        if (!isHyprland)
            return [];

        return workspace.toplevels.values.map(t => ({
                    "title": t.title || "Untitled",
                    "subtitle": t.lastIpcObject?.class ?? "",
                    "focused": t.activated,
                    "focus": () => Hyprland.dispatch("focuswindow address:0x" + t.address.replace(/^0x/, ""))
                }));
    }

    // Window classes only arrive over IPC on request.
    function refreshWindows() {
        if (isHyprland)
            Hyprland.refreshToplevels();
    }

    // The WindowManager module only binds the protocol once something reads it.
    Component.onCompleted: {
        if (isExt)
            WindowManager.windowsets.length;
    }

    // Hyprland: "activelayout>>keyboard,layout", one event per keyboard.
    Connections {
        target: root.isHyprland ? Hyprland : null

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.keyboardLayoutChanged(event.data.split(",").slice(1).join(","));
        }
    }

    // Sway: input events carry the device's new active layout. Only created under Sway/i3, as the
    // listener connects to the i3 socket as soon as it exists.
    LazyLoader {
        active: root.isI3

        I3IpcListener {
            subscriptions: ["input"]

            onIpcEvent: event => {
                const data = JSON.parse(event.data);

                if (data.change === "xkb_layout" && data.input?.xkb_active_layout_name)
                    root.keyboardLayoutChanged(data.input.xkb_active_layout_name);
            }
        }
    }
}
