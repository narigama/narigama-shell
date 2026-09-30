import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config

ColumnLayout {
    id: root

    property int month: clock.date.getMonth()
    property int year: clock.date.getFullYear()

    function shiftMonth(delta) {
        const date = new Date(year, month + delta, 1);

        month = date.getMonth();
        year = date.getFullYear();
    }

    width: 300
    spacing: 12

    SystemClock {
        id: clock

        precision: ShellState.clockSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, ShellState.timeFormat)
        color: Theme.primary
        font.pixelSize: 36
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
        color: Theme.fgMuted
    }

    RowLayout {
        Layout.fillWidth: true

        IconButton {
            icon: Icons.chevronLeft
            onClicked: root.shiftMonth(-1)
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            font.bold: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.month = clock.date.getMonth();
                    root.year = clock.date.getFullYear();
                }
            }
        }

        IconButton {
            icon: Icons.chevronRight
            onClicked: root.shiftMonth(1)
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale

        delegate: StyledText {
            required property string shortName

            horizontalAlignment: Text.AlignHCenter
            text: shortName.slice(0, 2)
            color: Theme.fgMuted
            font.bold: true
        }
    }

    MonthGrid {
        id: grid

        Layout.fillWidth: true
        Layout.preferredHeight: 6 * 32
        month: root.month
        year: root.year
        locale: Qt.locale()
        spacing: 0

        delegate: Rectangle {
            required property var model

            implicitHeight: 32
            color: model.today ? Theme.primary : "transparent"

            StyledText {
                anchors.centerIn: parent
                text: parent.model.day
                color: parent.model.today ? Theme.surface : parent.model.month === grid.month ? Theme.fg : Theme.fgSubtle
                font.bold: parent.model.today
            }
        }
    }
}
