import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    width: 420
    spacing: 8

    SectionHeader {
        text: SystemHealth.updates.length + " updates"

        IconButton {
            icon: Icons.refresh
            iconSize: Theme.fontSize + 2
            implicitHeight: 26
            foreground: Theme.fgMuted
            enabled: !SystemHealth.checkingUpdates
            onClicked: SystemHealth.checkUpdates()
        }
    }

    StyledText {
        visible: SystemHealth.checkingUpdates
        text: "Checking…"
        color: Theme.fgMuted
    }

    Repeater {
        model: SystemHealth.updates.slice(0, 40)

        delegate: RowLayout {
            required property var modelData

            Layout.fillWidth: true
            spacing: 12

            StyledText {
                Layout.fillWidth: true
                text: parent.modelData.name + (parent.modelData.aur ? "  (AUR)" : "")
                elide: Text.ElideRight
            }

            StyledText {
                text: (parent.modelData.from ? parent.modelData.from + " → " : "") + parent.modelData.to
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideLeft
                Layout.maximumWidth: 220
            }
        }
    }

    StyledText {
        visible: SystemHealth.updates.length > 40
        text: "and " + (SystemHealth.updates.length - 40) + " more"
        color: Theme.fgSubtle
    }

    IconButton {
        Layout.fillWidth: true
        Layout.topMargin: 4
        icon: Icons.terminal
        text: "Update in terminal"
        foreground: Theme.primary
        background: Theme.surface
        onClicked: {
            Dropdowns.close();
            SystemHealth.runUpdate();
        }
    }
}
