import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    width: 380
    spacing: 8

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

    RowLayout {
        Layout.fillWidth: true

        IconButton {
            icon: Icons.chevronLeft
            text: "Back"
            iconSize: Theme.fontSize + 2
            implicitHeight: 28
            onClicked: Dropdowns.current = "dashboard"
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: "Settings"
            color: Theme.fgMuted
            font.bold: true
        }
    }

    SectionHeader {
        Layout.topMargin: 4
        text: "Dark themes"
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

    SectionHeader {
        Layout.topMargin: 8
        text: "Bar modules"
    }

    Repeater {
        model: ShellState.modules

        delegate: SettingRow {
            required property var modelData

            label: modelData[1]

            Toggle {
                checked: ShellState.moduleVisible(modelData[0])
                onToggled: ShellState.setModuleVisible(modelData[0], !checked)
            }
        }
    }

    SectionHeader {
        Layout.topMargin: 8
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

    SectionHeader {
        Layout.topMargin: 8
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
        sample: "  " + [Icons.calendarClock, Icons.cpu, Icons.bell, Icons.archlinux].join(" ")
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

    SectionHeader {
        Layout.topMargin: 8
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
