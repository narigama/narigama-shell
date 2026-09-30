import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    width: 360
    spacing: 12

    Component.onCompleted: SystemStats.cpuProcessesWanted = true
    Component.onDestruction: SystemStats.cpuProcessesWanted = false

    RowLayout {
        Layout.fillWidth: true
        spacing: 16

        StyledText {
            text: Math.round(SystemStats.cpuPercent) + "%"
            color: Theme.blue
            font.pixelSize: 32
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                visible: !isNaN(SystemStats.cpuTemp)
                text: Icons.thermometer + " " + Math.round(SystemStats.cpuTemp) + "°C"
                color: SystemStats.cpuTemp >= 85 ? Theme.red : SystemStats.cpuTemp >= 70 ? Theme.yellow : Theme.fg
            }

            StyledText {
                text: "Load " + SystemStats.loadAverage.map(v => v.toFixed(2)).join("  ")
                color: Theme.fgMuted
            }
        }
    }

    Sparkline {
        Layout.fillWidth: true
        values: SystemStats.cpuHistory
        color: Theme.blue
    }

    SectionHeader {
        text: SystemStats.corePercents.length + " threads"
    }

    // One vertical bar per logical core.
    Row {
        id: cores

        readonly property int barWidth: Math.max(2, Math.floor((root.width - (SystemStats.corePercents.length - 1) * spacing) / Math.max(1, SystemStats.corePercents.length)))

        Layout.preferredHeight: 48
        spacing: 2

        Repeater {
            model: SystemStats.corePercents

            delegate: Rectangle {
                required property real modelData

                width: cores.barWidth
                height: 48
                color: Theme.elevated

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * Math.min(1, parent.modelData / 100)
                    color: parent.modelData >= 90 ? Theme.red : Theme.blue
                }
            }
        }
    }

    Repeater {
        model: SystemStats.gpus

        delegate: ColumnLayout {
            id: gpu

            required property var modelData

            Layout.fillWidth: true
            spacing: 4

            SectionHeader {
                text: gpu.modelData.name
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                StyledText {
                    text: Math.round(gpu.modelData.usage) + "%"
                    color: Theme.primary
                    font.bold: true
                }

                StyledText {
                    visible: !isNaN(gpu.modelData.temp)
                    text: Icons.thermometer + " " + Math.round(gpu.modelData.temp) + "°C"
                    color: gpu.modelData.temp >= 85 ? Theme.red : gpu.modelData.temp >= 70 ? Theme.yellow : Theme.fg
                }

                StyledText {
                    visible: !isNaN(gpu.modelData.power)
                    text: Icons.lightning + " " + Math.round(gpu.modelData.power) + " W"
                    color: Theme.fgMuted
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: (gpu.modelData.memUsed / 1024).toFixed(1) + " / " + (gpu.modelData.memTotal / 1024).toFixed(1) + " GiB"
                    color: Theme.fgMuted
                }
            }

            Sparkline {
                Layout.fillWidth: true
                implicitHeight: 32
                values: gpu.modelData.history ?? []
                color: Theme.primary
            }
        }
    }

    SectionHeader {
        text: "Top processes"
    }

    Repeater {
        model: SystemStats.topCpuProcesses

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
                Layout.preferredWidth: 64
                horizontalAlignment: Text.AlignRight
                text: parent.modelData.value.toFixed(1) + "%"
                color: Theme.blue
                font.bold: true
            }
        }
    }
}
