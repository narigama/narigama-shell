import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property var current: Weather.current
    readonly property var nextHours: Weather.hourly.filter(h => h.time > clock.date).slice(0, 8)

    width: 340
    spacing: 12

    SectionHeader {
        text: Weather.locationName

        IconButton {
            icon: Icons.refresh
            iconSize: Theme.fontSize
            implicitHeight: 24
            onClicked: Weather.refresh()
        }
    }

    StyledText {
        visible: Weather.error !== ""
        Layout.fillWidth: true
        text: "Weather unavailable: " + Weather.error
        color: Theme.red
        wrapMode: Text.Wrap
    }

    RowLayout {
        visible: root.current !== null
        spacing: 16

        StyledText {
            text: root.current ? Weather.icon(root.current.weather_code, root.current.is_day) : ""
            font.family: Theme.iconFontFamily
            color: Theme.yellow
            font.pixelSize: 56
        }

        ColumnLayout {
            spacing: 2

            StyledText {
                text: root.current ? Math.round(root.current.temperature_2m) + "°C" : ""
                color: Theme.primary
                font.pixelSize: 32
                font.bold: true
            }

            StyledText {
                text: root.current ? Weather.describe(root.current.weather_code) : ""
            }
        }
    }

    RowLayout {
        visible: root.current !== null
        Layout.fillWidth: true
        spacing: 16

        StyledText {
            text: root.current ? Icons.thermometer + " feels " + Math.round(root.current.apparent_temperature) + "°" : ""
            color: Theme.fgMuted
        }

        StyledText {
            text: root.current ? Icons.humidity + " " + root.current.relative_humidity_2m + "%" : ""
            color: Theme.fgMuted
        }

        StyledText {
            text: root.current ? Icons.wind + " " + Math.round(root.current.wind_speed_10m) + " km/h" : ""
            color: Theme.fgMuted
        }
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    RowLayout {
        visible: root.nextHours.length > 0
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        spacing: 0

        Repeater {
            model: root.nextHours

            delegate: ColumnLayout {
                required property var modelData

                // Equal preferred widths so the space is shared evenly across hours.
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatTime(parent.modelData.time, ShellState.clock24h ? "HH" : "h AP")
                    color: Theme.fgMuted
                    font.pixelSize: Theme.fontSize - 3
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Weather.icon(parent.modelData.code, parent.modelData.isDay)
                    font.family: Theme.iconFontFamily
                    color: Theme.yellow
                    font.pixelSize: Theme.iconSize - 2
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Math.round(parent.modelData.temp) + "°"
                    font.bold: true
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: parent.modelData.precipitation + "%"
                    color: parent.modelData.precipitation >= 50 ? Theme.blue : Theme.fgSubtle
                    font.pixelSize: Theme.fontSize - 3
                }
            }
        }
    }

    Repeater {
        model: Weather.daily

        delegate: RowLayout {
            required property var modelData
            required property int index

            Layout.fillWidth: true
            spacing: 12

            StyledText {
                Layout.preferredWidth: 48
                text: parent.index === 0 ? "Today" : Qt.formatDate(parent.modelData.date, "ddd")
                font.bold: true
            }

            StyledText {
                Layout.preferredWidth: 28
                text: Weather.icon(parent.modelData.code, true)
                font.family: Theme.iconFontFamily
                color: Theme.yellow
                font.pixelSize: Theme.iconSize
            }

            StyledText {
                Layout.fillWidth: true
                text: Weather.describe(parent.modelData.code)
                color: Theme.fgMuted
            }

            StyledText {
                text: parent.modelData.precipitation + "%"
                color: Theme.blue
            }

            StyledText {
                Layout.preferredWidth: 72
                horizontalAlignment: Text.AlignRight
                text: Math.round(parent.modelData.min) + "° / " + Math.round(parent.modelData.max) + "°"
            }
        }
    }

    StyledText {
        visible: root.current !== null
        text: "Updated " + Qt.formatTime(Weather.updatedAt, "HH:mm") + " · Open-Meteo"
        color: Theme.fgSubtle
        font.pixelSize: Theme.fontSize - 3
    }
}
