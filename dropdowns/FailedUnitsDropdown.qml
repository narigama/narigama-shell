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

    StyledText {
        visible: !Tools.available("failedUnits")
        Layout.fillWidth: true
        text: Tools.hint("failedUnits")
        color: Theme.yellow
        wrapMode: Text.Wrap
    }

    StyledText {
        visible: Tools.available("failedUnits") && SystemHealth.failedUnits.length === 0
        text: "No failed units"
        color: Theme.fgMuted
    }

    Repeater {
        model: SystemHealth.failedUnits

        delegate: ListRow {
            required property var modelData

            icon: Icons.alertCircle
            iconColor: Theme.red
            title: modelData.unit
            subtitle: (modelData.user ? "user · " : "") + modelData.description
            clickable: Tools.terminalCommand.length > 0
            onClicked: {
                Dropdowns.close();
                SystemHealth.showUnitStatus(modelData);
            }
        }

    }

    StyledText {
        visible: Tools.available("failedUnits")
        Layout.topMargin: 4
        Layout.fillWidth: true
        text: Tools.terminalHint !== "" ? Tools.terminalHint : "Click a unit to open its status and log in a terminal"
        color: Tools.terminalHint !== "" ? Theme.yellow : Theme.fgSubtle
        font.pixelSize: Theme.fontSize - 2
        wrapMode: Text.Wrap
    }

}
