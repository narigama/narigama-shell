import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 360
    spacing: 12

    Component.onCompleted: SystemHealth.refreshDisks()

    Repeater {
        model: SystemHealth.disks

        delegate: ColumnLayout {
            id: disk

            required property var modelData
            readonly property real fraction: modelData.used / Math.max(1, modelData.size)

            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: disk.modelData.mount
                    elide: Text.ElideMiddle
                }

                StyledText {
                    text: SystemHealth.formatBytes(disk.modelData.avail) + " free"
                    color: Theme.fgMuted
                }
            }

            Meter {
                Layout.fillWidth: true
                value: disk.fraction
                accent: disk.fraction >= 0.9 ? Theme.red : disk.fraction >= 0.75 ? Theme.yellow : Theme.blue
            }

            StyledText {
                text: SystemHealth.formatBytes(disk.modelData.used) + " of " + SystemHealth.formatBytes(disk.modelData.size) + " · " + Math.round(100 * disk.fraction) + "%"
                color: Theme.fgSubtle
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
