import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

// Settings laid out in columns across the full width of the tray that opens above the bar.
GridLayout {
    id: root

    columns: Math.max(2, Math.min(5, Math.floor(width / 320)))
    columnSpacing: 32
    rowSpacing: 24

    component SettingRow: RowLayout {
        property string label
        default property alias control: controlSlot.data

        Layout.fillWidth: true
        spacing: 8

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        Item {
            id: controlSlot

            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }

    component ThemeSwatch: Rectangle {
        id: swatch

        required property var theme
        readonly property bool selected: ShellState.theme === theme.id

        Layout.fillWidth: true
        implicitHeight: 36
        color: theme.colors.surface
        border.color: selected ? theme.colors.primary : swatchMouse.containsMouse ? theme.colors.fgMuted : theme.colors.elevated
        border.width: selected ? 2 : 1

        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: dots.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: swatch.theme.name
            color: swatch.theme.colors.fg
            font.pixelSize: Theme.fontSize - 2
            font.bold: swatch.selected
        }

        Row {
            id: dots

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Repeater {
                model: ["primary", "red", "yellow", "green", "blue"]

                delegate: Rectangle {
                    required property string modelData

                    width: 6
                    height: 14
                    color: swatch.theme.colors[modelData]
                }
            }
        }

        MouseArea {
            id: swatchMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ShellState.theme = swatch.theme.id
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        spacing: 8

        SectionHeader {
            text: "Dark themes"
        }

        StyledText {
            visible: Theme.fromWallpaper
            Layout.fillWidth: true
            text: "Colours currently come from the wallpaper (Wallpapers tab)"
            color: Theme.yellow
            font.pixelSize: Theme.fontSize - 2
            wrapMode: Text.Wrap
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: Themes.list.filter(t => !t.light)

                delegate: ThemeSwatch {
                    required property var modelData

                    theme: modelData
                }
            }
        }

        SectionHeader {
            Layout.topMargin: 4
            text: "Light themes"
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: Themes.list.filter(t => t.light)

                delegate: ThemeSwatch {
                    required property var modelData

                    theme: modelData
                }
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        spacing: 8

        SectionHeader {
            text: "Bar"
        }

        SettingRow {
            label: "Position"

            Row {
                spacing: 4

                Repeater {
                    model: [["top", "Top"], ["bottom", "Bottom"]]

                    delegate: IconButton {
                        required property var modelData

                        text: modelData[1]
                        implicitHeight: 26
                        active: ShellState.barPosition === modelData[0]
                        background: Theme.surface
                        onClicked: ShellState.barPosition = modelData[0]
                    }
                }
            }
        }

        SectionHeader {
            Layout.topMargin: 8
            text: "Bar modules"
        }

        StyledText {
            Layout.fillWidth: true
            text: "Drag to reorder or move between groups"
            color: Theme.fgSubtle
            font.pixelSize: Theme.fontSize - 3
        }

        ModuleLayoutEditor {
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        spacing: 8

        SectionHeader {
            text: "Workspace labels"
        }

        Repeater {
            model: WorkspaceLabels.styles

            delegate: ListRow {
                required property var modelData

                implicitHeight: 34
                title: modelData[1]
                highlighted: ShellState.workspaceLabels === modelData[0]
                onClicked: ShellState.workspaceLabels = modelData[0]

                StyledText {
                    text: modelData[2]
                    color: ShellState.workspaceLabels === modelData[0] ? Theme.primary : Theme.fgMuted
                    font.bold: true
                }
            }
        }

        RowLayout {
            visible: ShellState.workspaceLabels === "custom"
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: customLabels

                Layout.fillWidth: true
                text: ShellState.workspaceCustomLabels
                placeholder: "web, code, chat, …"
                onAccepted: applyLabels.clicked()
            }

            IconButton {
                id: applyLabels

                text: "Set"
                foreground: Theme.primary
                enabled: customLabels.text !== ShellState.workspaceCustomLabels
                onClicked: ShellState.workspaceCustomLabels = customLabels.text
            }
        }

        SectionHeader {
            Layout.topMargin: 8
            text: "Clock"
        }

        SettingRow {
            label: "Show seconds"

            Toggle {
                checked: ShellState.clockSeconds
                onToggled: ShellState.clockSeconds = !ShellState.clockSeconds
            }
        }

        SettingRow {
            label: "24-hour"

            Toggle {
                checked: ShellState.clock24h
                onToggled: ShellState.clock24h = !ShellState.clock24h
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        spacing: 8

        SectionHeader {
            text: "Appearance"
        }

        FontPicker {
            label: "Text font"
            current: ShellState.fontFamily
            fonts: Fonts.textFonts
            onPicked: family => ShellState.fontFamily = family
        }

        FontPicker {
            label: "Icon font"
            current: ShellState.iconFontFamily
            fonts: Fonts.iconFonts
            sample: "  " + [Icons.calendarClock, Icons.cpu, Icons.bell, Icons.forDistro(Tools.distroId)].join(" ")
            onPicked: family => ShellState.iconFontFamily = family
        }

        SettingRow {
            label: "Font size"

            Stepper {
                value: ShellState.fontSize
                from: 10
                to: 24
                suffix: "px"
                onChanged: value => ShellState.fontSize = value
            }
        }

        SettingRow {
            label: "Icon size"

            Stepper {
                value: ShellState.iconSize
                from: 14
                to: 36
                suffix: "px"
                onChanged: value => ShellState.iconSize = value
            }
        }

        SettingRow {
            label: "On-screen popups (volume, media…)"

            Toggle {
                checked: ShellState.osdEnabled
                onToggled: ShellState.osdEnabled = !ShellState.osdEnabled
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        spacing: 8

        SectionHeader {
            text: "Weather"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: location

                Layout.fillWidth: true
                text: ShellState.weatherLocation
                placeholder: "City"
                onAccepted: applyLocation.clicked()
            }

            IconButton {
                id: applyLocation

                text: "Set"
                foreground: Theme.primary
                enabled: location.text.trim() !== "" && location.text.trim() !== ShellState.weatherLocation
                onClicked: ShellState.weatherLocation = location.text.trim()
            }
        }

        StyledText {
            visible: ShellState.weatherLocation === ""
            Layout.fillWidth: true
            text: "Set a city to show the weather"
            color: Theme.yellow
            font.pixelSize: Theme.fontSize - 2
        }

        StyledText {
            visible: Weather.error !== ""
            Layout.fillWidth: true
            text: Weather.error
            color: Theme.red
            font.pixelSize: Theme.fontSize - 2
        }

        SectionHeader {
            Layout.topMargin: 8
            text: "Notifications"
        }

        SettingRow {
            label: "Popup duration"

            Stepper {
                value: ShellState.popupSeconds
                from: 1
                to: 30
                suffix: "s"
                onChanged: value => ShellState.popupSeconds = value
            }
        }

        StyledText {
            Layout.topMargin: 4
            text: "Popup position"
        }

        Repeater {
            model: [["top", "Top"], ["bottom", "Bottom"]]

            delegate: RowLayout {
                id: positionRow

                required property var modelData

                Layout.fillWidth: true
                spacing: 4

                StyledText {
                    Layout.preferredWidth: 64
                    text: positionRow.modelData[1]
                    color: Theme.fgMuted
                }

                Repeater {
                    model: [["left", "Left"], ["center", "Centre"], ["right", "Right"]]

                    delegate: IconButton {
                        required property var modelData
                        readonly property string position: positionRow.modelData[0] + "-" + modelData[0]

                        Layout.fillWidth: true
                        text: modelData[1]
                        implicitHeight: 26
                        active: ShellState.popupPosition === position
                        background: Theme.surface
                        onClicked: ShellState.popupPosition = position
                    }
                }
            }
        }

        SettingRow {
            label: "Popups shown at once"

            Stepper {
                value: ShellState.popupMax
                from: 1
                to: 10
                onChanged: value => ShellState.popupMax = value
            }
        }

        StyledText {
            visible: ShellState.mutedApps.length > 0
            Layout.topMargin: 4
            text: "Muted apps (history only, no popups)"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
            model: ShellState.mutedApps

            delegate: ListRow {
                required property string modelData

                implicitHeight: 34
                icon: Icons.bellOff
                iconColor: Theme.red
                title: modelData
                onClicked: Notifications.setMuted(modelData, false)

                StyledText {
                    text: "Unmute"
                    color: Theme.primary
                }
            }
        }
    }
}
