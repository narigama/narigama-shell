import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property var memory: SystemStats.memory

    function gib(kb) {
        return (kb / 1048576).toFixed(1) + " GiB";
    }

    width: 340
    spacing: 12

    Component.onCompleted: SystemStats.ramProcessesWanted = true
    Component.onDestruction: SystemStats.ramProcessesWanted = false

    component Stat: RowLayout {
        property string label
        property string value

        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: parent.label
            color: Theme.fgMuted
        }

        StyledText {
            text: parent.value
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 16

        StyledText {
            text: Math.round(SystemStats.ramPercent) + "%"
            color: Theme.green
            font.pixelSize: 32
            font.bold: true
        }

        StyledText {
            Layout.fillWidth: true
            text: root.gib(root.memory.used) + " of " + root.gib(root.memory.total)
            color: Theme.fgMuted
        }
    }

    Meter {
        Layout.fillWidth: true
        value: root.memory.used / Math.max(1, root.memory.total)
        accent: Theme.green
    }

    Sparkline {
        Layout.fillWidth: true
        values: SystemStats.ramHistory
        color: Theme.green
    }

    Stat {
        label: "Available"
        value: root.gib(root.memory.available)
    }

    Stat {
        label: "Cached"
        value: root.gib(root.memory.cached)
    }

    Stat {
        label: "Buffers"
        value: root.gib(root.memory.buffers)
    }

    SectionHeader {
        visible: root.memory.swapTotal > 0
        text: "Swap"
    }

    Meter {
        visible: root.memory.swapTotal > 0
        Layout.fillWidth: true
        value: root.memory.swapUsed / Math.max(1, root.memory.swapTotal)
        accent: Theme.yellow
    }

    Stat {
        visible: root.memory.swapTotal > 0
        label: "Used"
        value: root.gib(root.memory.swapUsed) + " of " + root.gib(root.memory.swapTotal)
    }

    SectionHeader {
        text: "Top processes"
    }

    Repeater {
        model: SystemStats.topRamProcesses

        delegate: RowLayout {
            required property var modelData

            Layout.fillWidth: true
            spacing: 12

            StyledText {
                Layout.fillWidth: true
                text: parent.modelData.name
            }

            StyledText {
                text: parent.modelData.pid
                color: Theme.fgSubtle
            }

            StyledText {
                Layout.preferredWidth: 80
                horizontalAlignment: Text.AlignRight
                text: root.gib(parent.modelData.value)
                color: Theme.green
                font.bold: true
            }
        }
    }
}
