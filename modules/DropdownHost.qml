import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.components
import qs.config
import qs.dropdowns
import qs.services

// Per-screen window that slides the open dropdown down from under the bar.
// The surface stays mapped at a fixed size with input masked to the panel: mapping or
// resizing a layer lets the compositor fade/animate it, which should be a pure slide.
PanelWindow {
    id: host

    required property PanelWindow bar
    // Compared against instead of `screen`, which the window itself rewrites when mapped.
    required property ShellScreen targetScreen
    readonly property bool open: Dropdowns.current !== "" && Dropdowns.screen === targetScreen
    // Lags `Dropdowns.current` so content stays loaded while sliding closed.
    property string shown: ""
    property bool closing: false
    // Fully open and not sliding: size/position changes (switching dropdowns, live content) animate.
    readonly property bool settled: open && !closing && panel.y === 0
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
            "settings": settings,
            "privacy": privacy
        })

    screen: targetScreen
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: maxContentHeight + 2 * padding
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    mask: Region {
        item: host.open ? panel : null
    }

    WlrLayershell.namespace: "narigama-dropdown"
    // Above the outside-click catcher (Top) where that's in use.
    WlrLayershell.layer: Compositor.hasFocusGrab ? WlrLayer.Top : WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    onOpenChanged: {
        if (open) {
            closing = false;
            shown = Dropdowns.current;
            return;
        }

        // Already fully hidden (closed before the slide moved), so no y change will finish the close.
        closing = panel.y > -panel.height;

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

    Item {
        anchors.fill: parent

        Rectangle {
            id: panel

            x: Math.round(Math.max(host.gutter, Math.min(host.width - width - host.gutter, Dropdowns.anchorX - width / 2)))
            y: host.open ? 0 : -height
            // Dropdowns set an explicit width; their height follows content up to maxContentHeight.
            width: flick.width + 2 * host.padding
            height: flick.height + 2 * host.padding
            color: Theme.bg
            border.color: Theme.elevated
            border.width: 1
            focus: host.open

            Keys.onEscapePressed: Dropdowns.close()

            onYChanged: {
                if (!host.open && y <= -height) {
                    host.closing = false;
                    host.shown = "";
                }
            }

            Behavior on y {
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
            active: host.open
            windows: [host, host.bar]
            onCleared: Dropdowns.close()
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
        id: settings

        SettingsDropdown {}
    }
}
