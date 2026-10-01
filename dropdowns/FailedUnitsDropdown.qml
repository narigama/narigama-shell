import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 440
    spacing: 4

    Component.onCompleted: SystemHealth.refreshFailedUnits()

    SectionHeader {
        text: "Failed units"
    }

    Repeater {
        model: SystemHealth.failedUnits

        delegate: ListRow {
            required property var modelData

            icon: Icons.alertCircle
            iconColor: Theme.red
            title: modelData.unit
            subtitle: (modelData.user ? "user · " : "") + modelData.description
            onClicked: {
                Dropdowns.close();
                SystemHealth.showUnitStatus(modelData);
            }
        }
    }

    StyledText {
        Layout.topMargin: 4
        text: "Click a unit to open its status and log in a terminal"
        color: Theme.fgSubtle
        font.pixelSize: Theme.fontSize - 2
    }
}
