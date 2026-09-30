import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.components
import qs.config

ColumnLayout {
    id: root

    readonly property var workspaces: Hyprland.workspaces.values.slice().sort((a, b) => a.id - b.id)

    width: 380
    spacing: 4

    // Toplevel classes come from IPC and are only fetched on request.
    Component.onCompleted: Hyprland.refreshToplevels()

    Repeater {
        model: root.workspaces

        delegate: ColumnLayout {
            id: workspaceItem

            required property HyprlandWorkspace modelData
            required property int index

            Layout.fillWidth: true
            Layout.topMargin: index === 0 ? 0 : 8
            spacing: 0

            ListRow {
                icon: Icons.monitor
                iconColor: workspaceItem.modelData.active ? Theme.primary : Theme.fgMuted
                title: "Workspace " + WorkspaceLabels.label(workspaceItem.modelData)
                subtitle: (workspaceItem.modelData.monitor?.name ?? "") + " · " + workspaceItem.modelData.toplevels.values.length + " windows"
                highlighted: workspaceItem.modelData.focused
                onClicked: workspaceItem.modelData.activate()
            }

            Repeater {
                model: workspaceItem.modelData.toplevels.values

                delegate: ListRow {
                    required property HyprlandToplevel modelData

                    Layout.leftMargin: 24
                    title: modelData.title || "Untitled"
                    subtitle: modelData.lastIpcObject?.class ?? ""
                    highlighted: modelData.activated
                    onClicked: Hyprland.dispatch("focuswindow address:0x" + modelData.address.replace(/^0x/, ""))
                }
            }
        }
    }
}
