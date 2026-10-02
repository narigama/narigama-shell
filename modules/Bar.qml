import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.dropdowns
import qs.services

// The bar for one screen. Both edges have a window that stays mapped; only the current one reserves
// space and takes input. Changing position slides the content out of one and into the other, so
// no window ever moves (the compositor would animate that across the screen).
// Each window also has room for the settings tray: opening settings slides the bar away from its
// edge and reveals the tray behind it. Windows never resize; input is masked to what's visible.
Scope {
    id: bar

    required property ShellScreen modelData
    readonly property ShellScreen screen: modelData
    // Lags ShellState.barAtBottom until the content has slid out of the old edge.
    property bool placedAtBottom: false
    readonly property PanelWindow window: placedAtBottom ? bottomWindow : topWindow
    readonly property real height: Theme.barHeight

    // Tray tabs, opened like dropdowns by name.
    readonly property var trayTabs: [["settings", "Settings", Icons.cog], ["wallpapers", "Wallpapers", Icons.image]]
    readonly property bool trayOpen: trayTabs.some(t => t[0] === Dropdowns.current) && Dropdowns.screen === screen
    // Lags Dropdowns.current so the tab stays rendered while the tray slides closed.
    property string trayTab: "settings"
    readonly property Item trayPage: trayTab === "wallpapers" ? wallpaperLoader : settings
    readonly property int trayMaxHeight: Math.round(screen.height * 0.75)
    readonly property real trayHeight: Math.min(tabRow.implicitHeight + 16 + trayPage.implicitHeight + 2 * trayPadding, trayMaxHeight)

    onTrayOpenChanged: {
        if (trayOpen)
            trayTab = Dropdowns.current;
    }

    Connections {
        target: Dropdowns

        function onCurrentChanged() {
            if (bar.trayOpen)
                bar.trayTab = Dropdowns.current;
        }
    }
    readonly property int trayPadding: 24
    // How much of the tray is showing; the bar sits this far from its edge.
    property real trayShown: trayOpen ? trayHeight : 0
    // Extra distance the bar is pushed past its edge while moving between edges.
    property real edgeSlide: 0

    Behavior on trayShown {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutCubic
        }
    }

    component EdgeWindow: PanelWindow {
        id: edgeWindow

        required property bool bottomEdge
        readonly property bool current: bar.placedAtBottom === bottomEdge

        screen: bar.modelData
        anchors {
            top: !bottomEdge
            bottom: bottomEdge
            left: true
            right: true
        }
        implicitHeight: Theme.barHeight + bar.trayMaxHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: current ? Theme.barHeight : 0
        mask: Region {
            item: edgeWindow.current ? visibleArea : null
        }

        WlrLayershell.namespace: "narigama-bar"
        WlrLayershell.keyboardFocus: current && bar.trayOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    }

    EdgeWindow {
        id: topWindow

        bottomEdge: false
    }

    EdgeWindow {
        id: bottomWindow

        bottomEdge: true
    }

    Component.onCompleted: placedAtBottom = ShellState.barAtBottom

    Connections {
        target: ShellState

        function onBarPositionChanged() {
            moveAnimation.restart();
        }
    }

    // Slide everything (bar and any open tray) out past the current edge, hand the content to the
    // other edge's window, and slide back in.
    SequentialAnimation {
        id: moveAnimation

        NumberAnimation {
            target: bar
            property: "edgeSlide"
            to: bar.height + bar.trayShown
            duration: 160
            easing.type: Easing.InCubic
        }

        ScriptAction {
            script: bar.placedAtBottom = ShellState.barAtBottom
        }

        NumberAnimation {
            target: bar
            property: "edgeSlide"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // Modules whose tools are installed and that have something to show.
    function moduleAvailable(name) {
        if (!Tools.available(name))
            return false;

        if (name === "media")
            return Media.active !== null;

        if (name === "weather")
            return Weather.current !== null;

        if (name === "privacy")
            return Privacy.active;

        if (name === "updates")
            return SystemHealth.updates.length > 0;

        if (name === "failedUnits")
            return SystemHealth.failedUnits.length > 0;

        if (name === "gamemode")
            return Desk.gamemodeActive;

        if (name === "brightness")
            return Desk.displays.length > 0;

        // hyprpicker needs Hyprland's screencopy and layer behaviour.
        if (name === "colorPicker")
            return Compositor.isHyprland;

        return true;
    }

    readonly property var moduleComponents: ({
            "workspaces": workspacesModule,
            "media": mediaModule,
            "privacy": privacyModule,
            "weather": weatherModule,
            "clock": clockModule,
            "volume": volumeModule,
            "cpu": cpuModule,
            "ram": ramModule,
            "notifications": notificationsModule,
            "network": networkModule,
            "bluetooth": bluetoothModule,
            "dashboard": dashboardModule,
            "launcher": launcherModule,
            "disk": diskModule,
            "updates": updatesModule,
            "failedUnits": failedUnitsModule,
            "capture": captureModule,
            "clipboard": clipboardModule,
            "colorPicker": colorPickerModule,
            "brightness": brightnessModule,
            "idleInhibit": idleInhibitModule,
            "gamemode": gamemodeModule
        })

    Component {
        id: moduleSlot

        Loader {
            required property string modelData

            visible: ShellState.moduleVisible(modelData) && bar.moduleAvailable(modelData)
            sourceComponent: bar.moduleComponents[modelData] ?? null
        }
    }

    Component {
        id: workspacesModule

        Workspaces {
            screen: bar.screen
        }
    }

    Component {
        id: mediaModule

        MediaButton {}
    }

    Component {
        id: privacyModule

        PrivacyIndicator {}
    }

    Component {
        id: weatherModule

        WeatherButton {}
    }

    Component {
        id: clockModule

        Clock {}
    }

    Component {
        id: volumeModule

        Volume {}
    }

    Component {
        id: cpuModule

        Cpu {}
    }

    Component {
        id: ramModule

        Ram {}
    }

    Component {
        id: notificationsModule

        NotificationsButton {}
    }

    Component {
        id: networkModule

        Network {}
    }

    Component {
        id: bluetoothModule

        BluetoothButton {}
    }

    Component {
        id: dashboardModule

        Dashboard {}
    }

    Component {
        id: launcherModule

        LauncherButton {}
    }

    Component {
        id: diskModule

        DiskButton {}
    }

    Component {
        id: updatesModule

        UpdatesButton {}
    }

    Component {
        id: failedUnitsModule

        FailedUnitsButton {}
    }

    Component {
        id: captureModule

        CaptureButton {}
    }

    Component {
        id: clipboardModule

        ClipboardButton {}
    }

    Component {
        id: colorPickerModule

        ColorPickerButton {}
    }

    Component {
        id: brightnessModule

        BrightnessButton {}
    }

    Component {
        id: idleInhibitModule

        IdleInhibitButton {}
    }

    Component {
        id: gamemodeModule

        GamemodeIndicator {}
    }

    // Inhibits idle (screen lock, DPMS) while the idle inhibitor module is on; needs a visible surface.
    IdleInhibitor {
        window: bar.window
        enabled: Desk.idleInhibited
    }

    Item {
        id: content

        parent: bar.window.contentItem
        anchors.fill: parent

        // Bar strip and tray, measured from the window's screen edge.
        readonly property real stripY: bar.placedAtBottom ? height - bar.height - bar.trayShown + bar.edgeSlide : bar.trayShown - bar.edgeSlide

        // What's on screen (bar plus revealed tray), for the input mask.
        Item {
            id: visibleArea

            width: parent.width
            y: bar.placedAtBottom ? content.stripY : 0
            height: bar.placedAtBottom ? content.height - content.stripY : content.stripY + bar.height
        }

        Rectangle {
            id: tray

            width: parent.width
            height: bar.trayHeight
            y: bar.placedAtBottom ? content.stripY + bar.height : content.stripY - height
            color: Theme.bg
            focus: bar.trayOpen

            Keys.onEscapePressed: Dropdowns.close()

            // A sibling of the Flickable, since the Flickable moves its own children onto its content item.
            WheelScroll {
                flickable: trayFlick
            }

            Row {
                id: tabRow

                x: bar.trayPadding
                y: bar.trayPadding - 8
                spacing: 4

                Repeater {
                    model: bar.trayTabs

                    delegate: IconButton {
                        required property var modelData

                        icon: modelData[2]
                        text: modelData[1]
                        iconSize: Theme.fontSize + 2
                        implicitHeight: 30
                        active: bar.trayTab === modelData[0]
                        background: Theme.surface
                        onClicked: Dropdowns.current = modelData[0]
                    }
                }
            }

            Flickable {
                id: trayFlick

                anchors.fill: parent
                anchors.margins: bar.trayPadding
                anchors.topMargin: tabRow.y + tabRow.implicitHeight + 16
                contentWidth: width
                contentHeight: bar.trayPage.implicitHeight
                interactive: false
                clip: true

                SettingsTray {
                    id: settings

                    visible: bar.trayTab === "settings"
                    width: trayFlick.width
                }

                // Created on demand: it rescans the folder each time it opens.
                Loader {
                    id: wallpaperLoader

                    active: bar.trayTab === "wallpapers" && (bar.trayOpen || bar.trayShown > 0)
                    visible: bar.trayTab === "wallpapers"
                    width: trayFlick.width

                    sourceComponent: WallpaperTray {
                        width: trayFlick.width
                    }
                }
            }

            IconButton {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                icon: Icons.close
                iconSize: Theme.fontSize + 2
                implicitHeight: 28
                foreground: Theme.fgMuted
                onClicked: Dropdowns.close()
            }
        }

        Rectangle {
            id: strip

            width: parent.width
            height: bar.height
            y: content.stripY
            color: Theme.surface

            Row {
                id: leftModules

                anchors.left: parent.left
                height: parent.height

                Repeater {
                    model: ShellState.layout.left
                    delegate: moduleSlot
                }
            }

            // Centred when there's room, otherwise pushed into the free space between the side groups,
            // and hidden rather than overlapping when even that is too narrow.
            Row {
                id: centerModules

                readonly property real gap: 16

                x: Math.max(leftModules.width + gap, Math.min((parent.width - width) / 2, rightModules.x - width - gap))
                height: parent.height
                visible: rightModules.x - leftModules.width >= implicitWidth + 2 * gap

                Repeater {
                    model: ShellState.layout.center
                    delegate: moduleSlot
                }
            }

            Row {
                id: rightModules

                anchors.right: parent.right
                height: parent.height

                Repeater {
                    model: ShellState.layout.right
                    delegate: moduleSlot
                }
            }
        }
    }
}
