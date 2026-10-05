import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.components
import qs.config
import qs.dropdowns
import qs.services

// Per-screen window that slides the open dropdown out of the bar's edge (down from a top bar,
// up from a bottom one).
// The surface keeps a fixed size with input masked to the panel, so the compositor never sees a
// resize; it's mapped only while needed (see `visible`).
PanelWindow {
    id: host

    // The screen's bar (modules/Bar.qml): its current window joins the focus grab, and its
    // settings tray is kept clear of the outside-click catcher.
    required property var barScope
    readonly property PanelWindow bar: barScope.window
    // Compared against instead of `screen`, which the window itself rewrites when mapped.
    required property ShellScreen targetScreen
    // Settings and wallpapers open as the bar's tray rather than a dropdown.
    readonly property bool open: Dropdowns.current !== "" && !barScope.trayTabs.some(t => t[0] === Dropdowns.current) && Dropdowns.screen === targetScreen
    // Lags `Dropdowns.current` so content stays loaded while sliding closed.
    property string shown: ""
    property bool closing: false
    // Fully open and not sliding: size/position changes (switching dropdowns, live content) animate.
    // Tracked by time rather than position: on a bottom bar the open position moves with the height.
    property bool slidIn: false
    readonly property bool settled: open && !closing && slidIn
    readonly property bool atBottom: ShellState.barAtBottom
    readonly property int padding: 16
    readonly property int gutter: 8
    readonly property int maxContentHeight: Math.round(targetScreen.height * 0.8)
    // Synced a tick after content changes rather than bound: dropdowns backed by live data
    // (e.g. wifi scans) can change size mid-layout, which a direct binding reports as a loop.
    property real contentHeight: 0

    function syncContentHeight() {
        contentHeight = loader.implicitHeight;
    }

    readonly property var components: ({
            "calendar": calendar,
            "weather": weather,
            "media": media,
            "audio": audio,
            "network": network,
            "bluetooth": bluetooth,
            "notifications": notifications,
            "dashboard": dashboard,
            "cpu": cpu,
            "ram": ram,
            "workspaces": workspaces,
            "privacy": privacy,
            "launcher": launcherDropdown,
            "disk": diskDropdown,
            "updates": updatesDropdown,
            "failedUnits": failedUnitsDropdown,
            "capture": captureDropdown,
            "clipboard": clipboardDropdown,
            "colors": colorsDropdown,
            "brightness": brightnessDropdown
        })

    screen: targetScreen
    // Mapped only while a dropdown is open or sliding shut: mapping makes Hyprland recompute what's
    // under the pointer, so a click on content that appeared under a still pointer isn't lost. The
    // compositor's map/unmap animation should be off for these surfaces (see README).
    visible: open || closing
    anchors {
        top: !host.atBottom
        bottom: host.atBottom
        left: true
        right: true
    }
    implicitHeight: maxContentHeight + 2 * padding
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    // The panel's resting place, not its sliding geometry: when the surface maps, the pointer is
    // already inside the input region, so Hyprland gives it pointer focus without needing motion.
    mask: Region {
        item: host.open ? restingArea : null
    }

    WlrLayershell.namespace: "narigama-dropdown"
    // Above the outside-click catcher (Top) where that's in use.
    WlrLayershell.layer: Compositor.hasFocusGrab ? WlrLayer.Top : WlrLayer.Overlay
    // The launcher is usually opened from a keybinding and must take typing straight away. Hyprland's
    // focus grab hands it the keyboard; elsewhere it needs exclusive focus. (On Hyprland exclusive
    // focus would also swallow every click outside it.)
    WlrLayershell.keyboardFocus: !open ? WlrKeyboardFocus.None : Dropdowns.current === "launcher" && !Compositor.hasFocusGrab ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    onOpenChanged: {
        slidIn = false;

        if (open) {
            closing = false;
            shown = Dropdowns.current;
            nudge.restart();
            slideTimer.restart();
            return;
        }

        // Already fully hidden (closed before the slide moved), so no y change will finish the close.
        closing = panel.y !== panel.hiddenY;

        if (!closing)
            shown = "";
    }

    Connections {
        target: Dropdowns

        function onCurrentChanged() {
            if (host.open)
                host.shown = Dropdowns.current;
        }
    }

    // Once the surface has mapped, so Hyprland notices it under a still pointer.
    Timer {
        id: nudge

        interval: 40
        onTriggered: Compositor.nudgePointer()
    }

    Timer {
        id: slideTimer

        interval: 200
        onTriggered: host.slidIn = host.open
    }

    Item {
        anchors.fill: parent

        Item {
            id: restingArea

            x: panel.x
            y: panel.openY
            width: panel.width
            height: panel.height
        }

        Rectangle {
            id: panel

            readonly property real openY: host.atBottom ? host.height - height : 0
            readonly property real hiddenY: host.atBottom ? host.height : -height

            x: Math.round(Math.max(host.gutter, Math.min(host.width - width - host.gutter, Dropdowns.anchorX - width / 2)))
            y: host.open ? openY : hiddenY
            // Dropdowns set an explicit width; their height follows content up to maxContentHeight.
            width: flick.width + 2 * host.padding
            height: flick.height + 2 * host.padding
            color: Theme.bg
            border.color: Theme.elevated
            border.width: 1
            focus: host.open

            Keys.onEscapePressed: Dropdowns.close()

            onYChanged: {
                if (!host.open && y === hiddenY) {
                    host.closing = false;
                    host.shown = "";
                }
            }

            // Only the open/close slide animates y; once settled, y tracks the (animated) height.
            Behavior on y {
                enabled: !host.settled

                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on x {
                enabled: host.settled

                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            // A sibling of the Flickable, since the Flickable moves its own children onto its content item.
            WheelScroll {
                flickable: flick
            }

            Flickable {
                id: flick

                x: host.padding
                y: host.padding
                width: loader.item?.width ?? 0
                height: Math.min(host.contentHeight, host.maxContentHeight)
                contentWidth: width
                contentHeight: host.contentHeight
                // Mouse-driven desktop UI: wheel only, via WheelScroll, no drag-to-flick.
                interactive: false
                clip: true

                Behavior on width {
                    enabled: host.settled

                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    enabled: host.settled

                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Loader {
                    id: loader

                    active: host.shown !== ""
                    sourceComponent: host.components[host.shown] ?? null

                    onLoaded: host.syncContentHeight()
                    onImplicitHeightChanged: Qt.callLater(host.syncContentHeight)
                }
            }
        }
    }

    // Clicking outside closes the dropdown. Hyprland's focus grab does this cleanly; elsewhere an
    // invisible layer under the bar takes input while any dropdown is open (that click is consumed).
    LazyLoader {
        active: Compositor.hasFocusGrab

        HyprlandFocusGrab {
            id: grab

            // Off briefly while re-arming after a spurious clear.
            property bool rearming: false

            active: (host.open || host.barScope.trayOpen) && !rearming
            windows: [host, host.bar]
            // Handing over from a menu to the tray (or between menus) changes which surfaces take
            // input, and Hyprland sometimes reads that as a click outside; re-arm instead of closing.
            onCleared: {
                if (Date.now() - Dropdowns.changedAt < 200) {
                    rearming = true;
                    Qt.callLater(() => grab.rearming = false);
                    return;
                }

                Dropdowns.close();
            }
        }
    }

    LazyLoader {
        active: !Compositor.hasFocusGrab

        PanelWindow {
            screen: host.targetScreen
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0
            mask: Region {
                item: Dropdowns.current !== "" ? catcher : null

                // The open settings tray overlaps this window; leave it clickable.
                Region {
                    y: ShellState.barAtBottom ? catcher.height - host.barScope.trayShown : 0
                    width: catcher.width
                    height: host.barScope.trayShown
                    intersection: Intersection.Subtract
                }
            }

            WlrLayershell.namespace: "narigama-dropdown-catcher"
            WlrLayershell.layer: WlrLayer.Top

            MouseArea {
                id: catcher

                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: Dropdowns.close()
            }
        }
    }

    Component {
        id: calendar

        CalendarDropdown {}
    }

    Component {
        id: weather

        WeatherDropdown {}
    }

    Component {
        id: media

        MediaDropdown {}
    }

    Component {
        id: audio

        AudioDropdown {}
    }

    Component {
        id: network

        NetworkDropdown {}
    }

    Component {
        id: bluetooth

        BluetoothDropdown {}
    }

    Component {
        id: notifications

        NotificationsDropdown {}
    }

    Component {
        id: dashboard

        DashboardDropdown {}
    }

    Component {
        id: cpu

        CpuDropdown {}
    }

    Component {
        id: ram

        RamDropdown {}
    }

    Component {
        id: workspaces

        WorkspacesDropdown {}
    }

    Component {
        id: privacy

        PrivacyDropdown {}
    }

    Component {
        id: diskDropdown

        DiskDropdown {}
    }

    Component {
        id: updatesDropdown

        UpdatesDropdown {}
    }

    Component {
        id: failedUnitsDropdown

        FailedUnitsDropdown {}
    }

    Component {
        id: captureDropdown

        CaptureDropdown {}
    }

    Component {
        id: clipboardDropdown

        ClipboardDropdown {}
    }

    Component {
        id: colorsDropdown

        ColorsDropdown {}
    }

    Component {
        id: brightnessDropdown

        BrightnessDropdown {}
    }

    Component {
        id: launcherDropdown

        LauncherDropdown {}
    }
}
